<%-- ============================================================
     controllerLibro.jsp
     Controlador JSP para la gestión de libros.
     Acciones soportadas (parámetro "action"):
       - guardar : Registra un nuevo libro, muestra confirmación con
                   jsp:getProperty y ofrece vínculo a la lista.
     Si no hay action, redirige al formulario de nuevo libro.
     ============================================================ --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.LibroBean, udb.biblioteca.CategoriaBean, java.sql.SQLException, java.util.List" %>

<%-- ── 1. Incluir conexión centralizada (expone objeto "conn") ── --%>
<%@ include file="conexion.jsp" %>

<%-- ── 2. Instanciar y autorellenar el Bean desde el formulario ──
         jsp:setProperty property="*" mapea automáticamente los campos:
           titulo, autor, isbn, id_categoria, cantidad_disponible --%>
<jsp:useBean id="libroBean" class="udb.biblioteca.LibroBean" scope="page" />
<jsp:setProperty name="libroBean" property="*" />

<%
    /* ── 3. Inyectar la conexión al bean para sus métodos de negocio ── */
    libroBean.setConn(conn);

    String action  = request.getParameter("action");
    String mensaje = null;
    boolean exito  = false;
    boolean error  = false;

    if ("guardar".equals(action)) {
        /* ── 4. Validación mínima del lado servidor ── */
        if (libroBean.getTitulo() == null || libroBean.getTitulo().trim().isEmpty() ||
            libroBean.getAutor()  == null || libroBean.getAutor().trim().isEmpty()) {

            mensaje = "El título y el autor son campos obligatorios.";
            error   = true;
        } else {
            try {
                /* ── 5. Persistir el libro usando PreparedStatement en el Bean ── */
                libroBean.guardar();
                exito = true;

                /* Cargar nombre de categoría para mostrarlo en la confirmación */
                CategoriaBean catBean = new CategoriaBean();
                CategoriaBean catEncontrada = catBean.obtenerPorId(conn, libroBean.getId_categoria());
                if (catEncontrada != null) {
                    libroBean.setCategoria(catEncontrada);
                }

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                mensaje = "El ISBN ingresado ya existe en el sistema. Verifique el dato.";
                error   = true;
            } catch (SQLException e) {
                mensaje = "Error de base de datos: " + e.getMessage();
                error   = true;
            }
        }
    }

    /* ── 6. Si hubo error, redirigir al formulario con mensaje ── */
    if (error) {
        if (conn != null && !conn.isClosed()) conn.close();
        response.sendRedirect("registroLibro.jsp?error=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
        return;
    }

    /* ── 7. Acceso directo sin action ── */
    if (!exito) {
        if (conn != null && !conn.isClosed()) conn.close();
        response.sendRedirect("registroLibro.jsp");
        return;
    }
    /* Si llegamos aquí, exito=true → renderizar confirmación */
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Libro Registrado – Biblioteca UDB</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp"><i class="bi bi-book-half me-2"></i>Biblioteca UDB</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link active" href="registroLibro.jsp"><i class="bi bi-journal-plus me-1"></i>Libros</a></li>
                <li class="nav-item"><a class="nav-link" href="registroEstudiante.jsp"><i class="bi bi-person-plus me-1"></i>Estudiantes</a></li>
                <li class="nav-item"><a class="nav-link" href="registroPrestamo.jsp"><i class="bi bi-arrow-left-right me-1"></i>Préstamos</a></li>
                <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-5" style="max-width: 680px;">
    <div class="card shadow border-0">
        <div class="card-header bg-success text-white">
            <h5 class="mb-0"><i class="bi bi-check-circle-fill me-2"></i>¡Libro registrado exitosamente!</h5>
        </div>
        <div class="card-body p-4">
            <p class="text-muted mb-4">Se han guardado los siguientes datos en el sistema:</p>

            <%-- ── Confirmación usando jsp:getProperty (requerimiento de rúbrica) ── --%>
            <table class="table table-bordered table-sm">
                <tbody>
                <tr>
                    <th class="bg-light" style="width:40%">Título</th>
                    <td><jsp:getProperty name="libroBean" property="titulo" /></td>
                </tr>
                <tr>
                    <th class="bg-light">Autor</th>
                    <td><jsp:getProperty name="libroBean" property="autor" /></td>
                </tr>
                <tr>
                    <th class="bg-light">ISBN</th>
                    <td>
                        <% String isbnMostrar = libroBean.getIsbn();
                           out.print(isbnMostrar != null && !isbnMostrar.isEmpty() ? isbnMostrar : "No especificado");
                        %>
                    </td>
                </tr>
                <tr>
                    <th class="bg-light">Categoría</th>
                    <td><%= libroBean.getNombreCategoria().isEmpty() ? "Sin categoría" : libroBean.getNombreCategoria() %></td>
                </tr>
                <tr>
                    <th class="bg-light">Cantidad disponible</th>
                    <td>
                        <span class="badge bg-success px-3">
                            <jsp:getProperty name="libroBean" property="cantidad_disponible" /> ejemplar(es)
                        </span>
                    </td>
                </tr>
                </tbody>
            </table>

            <div class="d-flex gap-2 mt-3">
                <a href="registroLibro.jsp" class="btn btn-primary">
                    <i class="bi bi-plus-circle me-1"></i>Registrar otro libro
                </a>
                <a href="listaLibros.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-journal-richtext me-1"></i>Ver catálogo
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    if (conn != null && !conn.isClosed()) conn.close();
%>
