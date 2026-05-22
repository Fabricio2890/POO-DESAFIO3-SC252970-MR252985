package udb.biblioteca;
import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoriaBean implements Serializable {

    private static final long serialVersionUID = 1L;

    // Atributos privados — encapsulamiento completo

    private int        id_categoria;
    private String     nombre_categoria;

    // Conexión inyectada desde el controlador JSP
    private transient Connection conn;

    // Constructor público sin argumentos

    public CategoriaBean() { }

    // Getters y Setters estándar (camelCase)

    public int getId_categoria() { return id_categoria; }
    public void setId_categoria(int id_categoria) { this.id_categoria = id_categoria; }

    public String getNombre_categoria() { return nombre_categoria; }
    public void setNombre_categoria(String nombre_categoria) { this.nombre_categoria = nombre_categoria; }

    /** Inyectar conexión desde el controlador JSP después de jsp:setProperty. */
    public Connection getConn() { return conn; }
    public void setConn(Connection conn) { this.conn = conn; }


    // Métodos de lógica de negocio

    /**
     * Retorna todas las categorías de la BD.
     * Requiere que setConn(conn) haya sido llamado previamente.
     * Usado en vistas y desplegables <select>.
     *
     * @return ArrayList<CategoriaBean> con todas las categorías.
     * @throws SQLException si la consulta falla.
     */
    public List<CategoriaBean> getListaCategorias() throws SQLException {
        List<CategoriaBean> lista = new ArrayList<>();

        String sql = "SELECT id_categoria, nombre_categoria "
                   + "FROM categorias ORDER BY nombre_categoria";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                CategoriaBean c = new CategoriaBean();
                c.setId_categoria(rs.getInt("id_categoria"));
                c.setNombre_categoria(rs.getString("nombre_categoria"));
                lista.add(c);
            }
        }
        return lista;
    }

    /**
     * Busca una categoría por su ID.
     *
     * @param conn        Conexión JDBC activa.
     * @param idCategoria ID de la categoría.
     * @return CategoriaBean encontrado o null.
     * @throws SQLException si la consulta falla.
     */
    public CategoriaBean obtenerPorId(Connection conn, int idCategoria) throws SQLException {
        String sql = "SELECT id_categoria, nombre_categoria "
                   + "FROM categorias WHERE id_categoria = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCategoria);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CategoriaBean c = new CategoriaBean();
                    c.setId_categoria(rs.getInt("id_categoria"));
                    c.setNombre_categoria(rs.getString("nombre_categoria"));
                    return c;
                }
            }
        }
        return null;
    }

    // ================================================================
    // toString
    // ================================================================
    @Override
    public String toString() {
        return "CategoriaBean{id=" + id_categoria + ", nombre='" + nombre_categoria + "'}";
    }
}
