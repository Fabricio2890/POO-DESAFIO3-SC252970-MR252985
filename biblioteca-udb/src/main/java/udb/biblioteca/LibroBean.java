package udb.biblioteca;

import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

class LibroBean implements Serializable {

    private static final long serialVersionUID = 1L;

    // Atributos privados — nombres IDÉNTICOS a columnas de la tabla

    private int           id_libro;
    private String        titulo;
    private String        autor;
    private String        isbn;
    private int           id_categoria;
    private int           cantidad_disponible;

    // Objeto compuesto
    private CategoriaBean categoria;

    // Conexión inyectada desde el controlador JSP
    private transient Connection conn;

    // Constructor público sin argumentos

    public LibroBean() {
        this.categoria = new CategoriaBean();
    }

    // Getters y Setters estándar

    public int getId_libro() { return id_libro; }
    public void setId_libro(int id_libro) { this.id_libro = id_libro; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public int getId_categoria() { return id_categoria; }
    public void setId_categoria(int id_categoria) { this.id_categoria = id_categoria; }

    public int getCantidad_disponible() { return cantidad_disponible; }
    public void setCantidad_disponible(int cantidad_disponible) { this.cantidad_disponible = cantidad_disponible; }

    public CategoriaBean getCategoria() { return categoria; }
    public void setCategoria(CategoriaBean categoria) { this.categoria = categoria; }

    /** Inyectar conexión desde el controlador JSP después de jsp:setProperty. */
    public Connection getConn() { return conn; }
    public void setConn(Connection conn) { this.conn = conn; }

    // Métodos de lógica de negocio

    /**
     * Retorna el nombre de la categoría del libro a través del objeto
     * CategoriaBean compuesto. Conveniente para jsp:getProperty y vistas.
     *
     * @return Nombre de la categoría, o cadena vacía si no está seteada.
     */
    public String getNombreCategoria() {
        if (this.categoria != null && this.categoria.getNombre_categoria() != null) {
            return this.categoria.getNombre_categoria();
        }
        return "";
    }

    /**
     * Indica si el libro tiene al menos 1 unidad disponible.
     *
     * @return true si cantidad_disponible > 0.
     */
    public boolean isDisponible() {
        return this.cantidad_disponible > 0;
    }

    /**
     * Retorna todos los libros con datos de categoría (JOIN).
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usado en el listado general de libros y en desplegables de préstamos.
     *
     * @return ArrayList<LibroBean> con objeto CategoriaBean anidado en cada uno.
     * @throws SQLException si la consulta falla.
     */
    public List<LibroBean> getListaLibros() throws SQLException {
        List<LibroBean> lista = new ArrayList<>();

        String sql =
            "SELECT l.id_libro, l.titulo, l.autor, l.isbn, "
          + "       l.id_categoria, l.cantidad_disponible, "
          + "       c.nombre_categoria "
          + "FROM libros l "
          + "LEFT JOIN categorias c ON l.id_categoria = c.id_categoria "
          + "ORDER BY l.titulo";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearFila(rs));
            }
        }
        return lista;
    }

    /**
     * Retorna únicamente los libros con stock disponible (cantidad_disponible > 0).
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usado en el <select> del formulario de nuevo préstamo.
     *
     * @return ArrayList<LibroBean> disponibles para préstamo.
     * @throws SQLException si la consulta falla.
     */
    public List<LibroBean> getListaLibrosDisponibles() throws SQLException {
        List<LibroBean> lista = new ArrayList<>();

        String sql =
            "SELECT l.id_libro, l.titulo, l.autor, l.isbn, "
          + "       l.id_categoria, l.cantidad_disponible, "
          + "       c.nombre_categoria "
          + "FROM libros l "
          + "LEFT JOIN categorias c ON l.id_categoria = c.id_categoria "
          + "WHERE l.cantidad_disponible > 0 "
          + "ORDER BY l.titulo";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearFila(rs));
            }
        }
        return lista;
    }

    /**
     * Busca un libro por su ID primario.
     *
     * @param conn    Conexión JDBC activa.
     * @param idLibro ID del libro.
     * @return LibroBean encontrado, o null si no existe.
     * @throws SQLException si la consulta falla.
     */
    public LibroBean obtenerPorId(Connection conn, int idLibro) throws SQLException {
        String sql =
            "SELECT l.id_libro, l.titulo, l.autor, l.isbn, "
          + "       l.id_categoria, l.cantidad_disponible, "
          + "       c.nombre_categoria "
          + "FROM libros l "
          + "LEFT JOIN categorias c ON l.id_categoria = c.id_categoria "
          + "WHERE l.id_libro = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idLibro);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapearFila(rs);
            }
        }
        return null;
    }

    /**
     * Persiste el libro actual en la base de datos.
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usa PreparedStatement — sin inyección SQL.
     *
     * @throws SQLException si la inserción falla.
     */
    public void guardar() throws SQLException {
        String sql = "INSERT INTO libros (titulo, autor, isbn, id_categoria, cantidad_disponible) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, this.titulo);
            ps.setString(2, this.autor);
            ps.setString(3, this.isbn);
            ps.setInt(4, this.id_categoria);
            ps.setInt(5, this.cantidad_disponible > 0 ? this.cantidad_disponible : 1);
            ps.executeUpdate();
        }
    }

    // ================================================================
    // Método auxiliar privado: mapea una fila de ResultSet a un LibroBean
    // ================================================================
    private LibroBean mapearFila(ResultSet rs) throws SQLException {
        LibroBean lb = new LibroBean();
        lb.setId_libro(rs.getInt("id_libro"));
        lb.setTitulo(rs.getString("titulo"));
        lb.setAutor(rs.getString("autor"));
        lb.setIsbn(rs.getString("isbn"));
        lb.setId_categoria(rs.getInt("id_categoria"));
        lb.setCantidad_disponible(rs.getInt("cantidad_disponible"));

        CategoriaBean cb = new CategoriaBean();
        cb.setId_categoria(rs.getInt("id_categoria"));
        cb.setNombre_categoria(rs.getString("nombre_categoria"));
        lb.setCategoria(cb);

        return lb;
    }

    // ================================================================
    // toString
    // ================================================================
    @Override
    public String toString() {
        return "LibroBean{id=" + id_libro + ", titulo='" + titulo
             + "', disponible=" + cantidad_disponible + "}";
    }
}
