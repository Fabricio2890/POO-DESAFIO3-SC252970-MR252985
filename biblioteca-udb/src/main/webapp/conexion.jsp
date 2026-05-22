<%-- ============================================================
     conexion.jsp
     Archivo de conexión centralizado a MySQL.
     Se incluye en cada controlador mediante:
         <%@ include file="conexion.jsp" %>
     NUNCA se accede directamente desde el navegador.
     ============================================================ --%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
    /* ---- Parámetros de conexión ---- */
    final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    final String DB_URL    = "jdbc:mysql://localhost:3306/bibliotecaudb"
                           + "?useSSL=false"
                           + "&serverTimezone=America/El_Salvador"
                           + "&allowPublicKeyRetrieval=true"
                           + "&characterEncoding=UTF-8";
    final String DB_USER   = "root";
    final String DB_PASS   = "";           // Sin contraseña

    /* ---- Objeto de conexión disponible en todo el controlador ---- */
    Connection conn = null;

    try {
        Class.forName(DB_DRIVER);
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    } catch (ClassNotFoundException e) {
        throw new ServletException("Driver MySQL no encontrado: " + e.getMessage(), e);
    } catch (SQLException e) {
        throw new ServletException("Error al conectar con la base de datos: " + e.getMessage(), e);
    }
%>
