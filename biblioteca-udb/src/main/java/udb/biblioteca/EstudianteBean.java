package udb.biblioteca;

import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * EstudianteBean.java
 * JavaBean que representa a un estudiante inscrito en el sistema de préstamos.
 *
 * Fase 2: Se agrega la propiedad "conn" inyectable y getListaEstudiantes()
 * sin argumentos para cumplir la convención JavaBean.
 *
 * Paquete: udb.biblioteca | Asignatura: POO404 - Universidad Don Bosco
 */
public class EstudianteBean implements Serializable {

    private static final long serialVersionUID = 1L;

    // ----------------------------------------------------------------
    // Atributos privados — nombres IDÉNTICOS a columnas de la tabla
    // para que jsp:setProperty property="*" funcione correctamente
    // ----------------------------------------------------------------
    private int    id_estudiante;
    private String carnet;
    private String nombre_estudiante;
    private String carrera;
    private String telefono;

    // Conexión inyectada desde el controlador JSP (no mapeada por formularios)
    private transient Connection conn;

    // ================================================================
    // Constructor público sin argumentos (OBLIGATORIO para JavaBeans)
    // ================================================================
    public EstudianteBean() { }

    // ================================================================
    // Getters y Setters estándar (camelCase)
    // ================================================================

    public int getId_estudiante() { return id_estudiante; }
    public void setId_estudiante(int id_estudiante) { this.id_estudiante = id_estudiante; }

    public String getCarnet() { return carnet; }
    public void setCarnet(String carnet) { this.carnet = carnet; }

    public String getNombre_estudiante() { return nombre_estudiante; }
    public void setNombre_estudiante(String nombre_estudiante) { this.nombre_estudiante = nombre_estudiante; }

    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    /** Inyectar conexión desde el controlador JSP después de jsp:setProperty. */
    public Connection getConn() { return conn; }
    public void setConn(Connection conn) { this.conn = conn; }

    // ================================================================
    // Métodos de lógica de negocio
    // ================================================================

    /**
     * Retorna todos los estudiantes ordenados por nombre.
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usado en el <select> del formulario de nuevo préstamo.
     *
     * @return ArrayList<EstudianteBean> con todos los estudiantes registrados.
     * @throws SQLException si la consulta falla.
     */
    public List<EstudianteBean> getListaEstudiantes() throws SQLException {
        List<EstudianteBean> lista = new ArrayList<>();

        String sql = "SELECT id_estudiante, carnet, nombre_estudiante, carrera, telefono "
                   + "FROM estudiantes ORDER BY nombre_estudiante";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EstudianteBean e = new EstudianteBean();
                e.setId_estudiante(rs.getInt("id_estudiante"));
                e.setCarnet(rs.getString("carnet"));
                e.setNombre_estudiante(rs.getString("nombre_estudiante"));
                e.setCarrera(rs.getString("carrera"));
                e.setTelefono(rs.getString("telefono"));
                lista.add(e);
            }
        }
        return lista;
    }

    /**
     * Busca un estudiante por su ID primario.
     *
     * @param conn         Conexión JDBC activa.
     * @param idEstudiante ID del estudiante.
     * @return EstudianteBean encontrado, o null si no existe.
     * @throws SQLException si la consulta falla.
     */
    public EstudianteBean obtenerPorId(Connection conn, int idEstudiante) throws SQLException {
        String sql = "SELECT id_estudiante, carnet, nombre_estudiante, carrera, telefono "
                   + "FROM estudiantes WHERE id_estudiante = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idEstudiante);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    EstudianteBean e = new EstudianteBean();
                    e.setId_estudiante(rs.getInt("id_estudiante"));
                    e.setCarnet(rs.getString("carnet"));
                    e.setNombre_estudiante(rs.getString("nombre_estudiante"));
                    e.setCarrera(rs.getString("carrera"));
                    e.setTelefono(rs.getString("telefono"));
                    return e;
                }
            }
        }
        return null;
    }

    /**
     * Persiste el estudiante actual en la base de datos.
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usa PreparedStatement — sin inyección SQL.
     *
     * @throws SQLException si la inserción falla (ej. carnet duplicado).
     */
    public void guardar() throws SQLException {
        String sql = "INSERT INTO estudiantes (carnet, nombre_estudiante, carrera, telefono) "
                   + "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, this.carnet);
            ps.setString(2, this.nombre_estudiante);
            ps.setString(3, this.carrera);
            ps.setString(4, this.telefono);
            ps.executeUpdate();
        }
    }

    // ================================================================
    // toString
    // ================================================================
    @Override
    public String toString() {
        return "EstudianteBean{id=" + id_estudiante + ", carnet='" + carnet
             + "', nombre='" + nombre_estudiante + "'}";
    }
}
