package udb.biblioteca;

import java.io.Serializable;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * PrestamoBean.java
 * JavaBean que representa un préstamo en el sistema de la Biblioteca UDB.
 *
 * Fase 2: Se agrega la propiedad "conn" inyectable y los métodos
 * getListaPrestamos(), guardar() y devolver() sin argumentos para cumplir
 * la convención JavaBean y poder ser invocados desde los controladores JSP.
 *
 * Reglas de negocio implementadas:
 *  - fecha_prestamo  = fecha actual del sistema (automática).
 *  - fecha_devolucion = fecha_prestamo + 9 días (automática).
 *  - Validación de stock antes de insertar (lanza IllegalStateException si = 0).
 *  - Devolución: estado → 'Devuelto' + stock del libro +1.
 *  - getEstadoPrestamo(): "Devuelto" | "Vencido" | "Vigente" (calculado dinámicamente).
 *
 * Paquete: udb.biblioteca | Asignatura: POO404 - Universidad Don Bosco
 */
public class PrestamoBean implements Serializable {

    private static final long serialVersionUID = 1L;

    // ----------------------------------------------------------------
    // Atributos privados — nombres IDÉNTICOS a columnas de la tabla
    // para que jsp:setProperty property="*" funcione correctamente
    // ----------------------------------------------------------------
    private int    id_prestamo;
    private int    id_estudiante;
    private int    id_libro;
    private String fecha_prestamo;    // Formato ISO yyyy-MM-dd (String para setProperty)
    private String fecha_devolucion;  // Formato ISO yyyy-MM-dd (String para setProperty)
    private String estado;            // Valor BD: 'Activo' | 'Devuelto'

    // Objetos compuestos — no son columnas directas, no mapeados por formularios
    private EstudianteBean estudiante;
    private LibroBean      libro;

    // Conexión inyectada desde el controlador JSP (no mapeada por formularios)
    private transient Connection conn;

    // ================================================================
    // Constructor público sin argumentos (OBLIGATORIO para JavaBeans)
    // ================================================================
    public PrestamoBean() {
        this.estudiante = new EstudianteBean();
        this.libro      = new LibroBean();
    }

    // ================================================================
    // Getters y Setters estándar (camelCase)
    // ================================================================

    public int getId_prestamo() { return id_prestamo; }
    public void setId_prestamo(int id_prestamo) { this.id_prestamo = id_prestamo; }

    public int getId_estudiante() { return id_estudiante; }
    public void setId_estudiante(int id_estudiante) { this.id_estudiante = id_estudiante; }

    public int getId_libro() { return id_libro; }
    public void setId_libro(int id_libro) { this.id_libro = id_libro; }

    public String getFecha_prestamo() { return fecha_prestamo; }
    public void setFecha_prestamo(String fecha_prestamo) { this.fecha_prestamo = fecha_prestamo; }

    public String getFecha_devolucion() { return fecha_devolucion; }
    public void setFecha_devolucion(String fecha_devolucion) { this.fecha_devolucion = fecha_devolucion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public EstudianteBean getEstudiante() { return estudiante; }
    public void setEstudiante(EstudianteBean estudiante) { this.estudiante = estudiante; }

    public LibroBean getLibro() { return libro; }
    public void setLibro(LibroBean libro) { this.libro = libro; }

    /** Inyectar conexión desde el controlador JSP después de jsp:setProperty. */
    public Connection getConn() { return conn; }
    public void setConn(Connection conn) { this.conn = conn; }

    // ================================================================
    // Métodos de lógica de negocio
    // ================================================================

    /**
     * Calcula el estado visual del préstamo dinámicamente.
     *
     * Reglas (en orden de prioridad):
     *  1. estado en BD = 'Devuelto'  → "Devuelto"
     *  2. estado = 'Activo' y fecha actual > fecha_devolucion → "Vencido"
     *  3. En cualquier otro caso → "Vigente"
     *
     * @return "Devuelto" | "Vencido" | "Vigente"
     */
    public String getEstadoPrestamo() {
        // Regla 1: Ya fue devuelto físicamente
        if ("Devuelto".equalsIgnoreCase(this.estado)) {
            return "Devuelto";
        }
        // Reglas 2 y 3: Comparar fecha actual contra límite de devolución
        try {
            LocalDate hoy        = LocalDate.now();
            LocalDate fechaDevol = LocalDate.parse(this.fecha_devolucion); // yyyy-MM-dd
            return hoy.isAfter(fechaDevol) ? "Vencido" : "Vigente";
        } catch (Exception e) {
            // Fallback: retornar estado crudo de BD si la fecha no puede parsearse
            return (this.estado != null) ? this.estado : "Desconocido";
        }
    }

    /**
     * Retorna todos los préstamos con datos completos via JOINs.
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Llena los objetos anidados EstudianteBean y LibroBean en cada fila.
     *
     * @return ArrayList<PrestamoBean> con todos los préstamos, ordenados DESC.
     * @throws SQLException si la consulta falla.
     */
    public List<PrestamoBean> getListaPrestamos() throws SQLException {
        List<PrestamoBean> lista = new ArrayList<>();

        String sql =
            "SELECT p.id_prestamo, p.id_estudiante, p.id_libro, "
          + "       p.fecha_prestamo, p.fecha_devolucion, p.estado, "
          + "       e.carnet, e.nombre_estudiante, e.carrera, e.telefono, "
          + "       l.titulo, l.autor, l.isbn, l.cantidad_disponible, "
          + "       c.id_categoria, c.nombre_categoria "
          + "FROM prestamos p "
          + "INNER JOIN estudiantes e ON p.id_estudiante = e.id_estudiante "
          + "INNER JOIN libros      l ON p.id_libro      = l.id_libro "
          + "LEFT  JOIN categorias  c ON l.id_categoria  = c.id_categoria "
          + "ORDER BY p.id_prestamo DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearFila(rs));
            }
        }
        return lista;
    }

    /**
     * Registra un nuevo préstamo en la base de datos.
     * Requiere que setConn(conn), setId_estudiante() y setId_libro() hayan sido llamados.
     *
     * Lógica automática:
     *  - fecha_prestamo  = LocalDate.now()
     *  - fecha_devolucion = now + 9 días
     *
     * Validación de stock:
     *  - Si cantidad_disponible = 0 → lanza IllegalStateException (sin inserción).
     *
     * Operaciones atómicas (misma transacción lógica):
     *  1. INSERT en prestamos con estado 'Activo'.
     *  2. UPDATE libros: cantidad_disponible - 1.
     *
     * @throws SQLException          si ocurre un error de BD.
     * @throws IllegalStateException si el libro no tiene stock disponible.
     */
    public void guardar() throws SQLException {
        // ---- 1. Validar stock disponible antes de insertar ----
        String sqlStock = "SELECT cantidad_disponible FROM libros WHERE id_libro = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
            ps.setInt(1, this.id_libro);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("cantidad_disponible") <= 0) {
                    throw new IllegalStateException(
                        "Sin stock: el libro seleccionado no tiene ejemplares disponibles.");
                }
            }
        }

        // ---- 2. Calcular fechas automáticamente ----
        LocalDate hoy        = LocalDate.now();
        LocalDate fechaDevol = hoy.plusDays(9);

        // ---- 3. Insertar el préstamo ----
        String sqlInsert =
            "INSERT INTO prestamos (id_estudiante, id_libro, fecha_prestamo, fecha_devolucion, estado) "
          + "VALUES (?, ?, ?, ?, 'Activo')";

        try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
            ps.setInt(1, this.id_estudiante);
            ps.setInt(2, this.id_libro);
            ps.setDate(3, Date.valueOf(hoy));
            ps.setDate(4, Date.valueOf(fechaDevol));
            ps.executeUpdate();
        }

        // ---- 4. Decrementar stock del libro ----
        String sqlUpdate =
            "UPDATE libros SET cantidad_disponible = cantidad_disponible - 1 "
          + "WHERE id_libro = ? AND cantidad_disponible > 0";

        try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setInt(1, this.id_libro);
            ps.executeUpdate();
        }
    }

    /**
     * Procesa la devolución de un préstamo.
     * Requiere que setConn(conn), setId_prestamo() y setId_libro() hayan sido llamados.
     *
     * Operaciones:
     *  1. UPDATE prestamos: estado → 'Devuelto'
     *  2. UPDATE libros:    cantidad_disponible + 1
     *
     * @throws SQLException si alguna actualización falla.
     */
    public void devolver() throws SQLException {
        // ---- 1. Marcar préstamo como Devuelto ----
        String sqlEstado = "UPDATE prestamos SET estado = 'Devuelto' WHERE id_prestamo = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlEstado)) {
            ps.setInt(1, this.id_prestamo);
            ps.executeUpdate();
        }

        // ---- 2. Incrementar stock del libro en +1 ----
        String sqlStock =
            "UPDATE libros SET cantidad_disponible = cantidad_disponible + 1 "
          + "WHERE id_libro = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
            ps.setInt(1, this.id_libro);
            ps.executeUpdate();
        }
    }

    // ================================================================
    // Método auxiliar privado: mapea una fila del ResultSet a un PrestamoBean
    // ================================================================
    private PrestamoBean mapearFila(ResultSet rs) throws SQLException {
        PrestamoBean pb = new PrestamoBean();

        // Datos propios del préstamo
        pb.setId_prestamo(rs.getInt("id_prestamo"));
        pb.setId_estudiante(rs.getInt("id_estudiante"));
        pb.setId_libro(rs.getInt("id_libro"));
        pb.setFecha_prestamo(rs.getString("fecha_prestamo"));
        pb.setFecha_devolucion(rs.getString("fecha_devolucion"));
        pb.setEstado(rs.getString("estado"));

        // Objeto anidado: estudiante
        EstudianteBean eb = new EstudianteBean();
        eb.setId_estudiante(rs.getInt("id_estudiante"));
        eb.setCarnet(rs.getString("carnet"));
        eb.setNombre_estudiante(rs.getString("nombre_estudiante"));
        eb.setCarrera(rs.getString("carrera"));
        eb.setTelefono(rs.getString("telefono"));
        pb.setEstudiante(eb);

        // Objeto anidado: libro + categoría
        LibroBean lb = new LibroBean();
        lb.setId_libro(rs.getInt("id_libro"));
        lb.setTitulo(rs.getString("titulo"));
        lb.setAutor(rs.getString("autor"));
        lb.setIsbn(rs.getString("isbn"));
        lb.setCantidad_disponible(rs.getInt("cantidad_disponible"));

        CategoriaBean cb = new CategoriaBean();
        cb.setId_categoria(rs.getInt("id_categoria"));
        cb.setNombre_categoria(rs.getString("nombre_categoria"));
        lb.setCategoria(cb);
        pb.setLibro(lb);

        return pb;
    }

    // ================================================================
    // toString
    // ================================================================
    @Override
    public String toString() {
        return "PrestamoBean{id=" + id_prestamo
             + ", idEstudiante=" + id_estudiante
             + ", idLibro=" + id_libro
             + ", estado='" + estado + "'"
             + ", estadoCalculado='" + getEstadoPrestamo() + "'}";
    }
}
