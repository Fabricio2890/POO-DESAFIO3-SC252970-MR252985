<%-- ============================================================
     controllerEstudiante.jsp
     Controlador JSP para la gestión de estudiantes.
     Acciones soportadas (parámetro "action"):
       - guardar : Registra un nuevo estudiante y muestra confirmación
                   usando jsp:getProperty (requerimiento de rúbrica).
     Si no hay action, redirige al formulario de nuevo estudiante.
     ============================================================ --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.EstudianteBean, java.sql.SQLException" %>

<%-- ── 1. Incluir conexión centralizada (expone objeto "conn") ── --%>
<%@ include file="conexion.jsp" %>

<%-- ── 2. Instanciar y autorellenar el Bean desde el formulario ──
         jsp:setProperty property="*" mapea automáticamente los campos:
           carnet, nombre_estudiante, carrera, telefono --%>
<jsp:useBean id="estudianteBean" class="udb.biblioteca.EstudianteBean" scope="page" />
<jsp:setProperty name="estudianteBean" property="*" />

<%
    /* ── 3. Inyectar la conexión al bean para sus métodos de negocio ── */
    estudianteBean.setConn(conn);

    String  action = request.getParameter("action");
    String  mensaje = null;
    boolean exito   = false;
    boolean error   = false;

    if ("guardar".equals(action)) {
        /* ── 4. Validación mínima del lado servidor ── */
        if (estudianteBean.getCarnet()           == null || estudianteBean.getCarnet().trim().isEmpty() ||
            estudianteBean.getNombre_estudiante() == null || estudianteBean.getNombre_estudiante().trim().isEmpty() ||
            estudianteBean.getCarrera()           == null || estudianteBean.getCarrera().trim().isEmpty()) {

            mensaje = "Carnet, nombre y carrera son campos obligatorios.";
            error   = true;
        } else {
            try {
                /* ── 5. Persistir el estudiante usando PreparedStatement en el Bean ── */
                estudianteBean.guardar();
                exito = true;

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                /* Carnet duplicado */
                mensaje = "El carnet ingresado ya está registrado en el sistema.";
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
        response.sendRedirect("registroEstudiante.jsp?error=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
        return;
    }

    /* ── 7. Acceso directo sin action ── */
    if (!exito) {
        if (conn != null && !conn.isClosed()) conn.close();
        response.sendRedirect("registroEstudiante.jsp");
        return;
    }
    /* Si llegamos aquí, exito=true → renderizar confirmación */
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Estudiante Registrado – Biblioteca UDB</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp"><i class="bi bi-book-half me-2"></i>Biblioteca UDB</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="registroLibro.jsp"><i class="bi bi-journal-plus me-1"></i>Libros</a></li>
                <li class="nav-item"><a class="nav-link active" href="registroEstudiante.jsp"><i class="bi bi-person-plus me-1"></i>Estudiantes</a></li>
                <li class="nav-item"><a class="nav-link" href="registroPrestamo.jsp"><i class="bi bi-arrow-left-right me-1"></i>Préstamos</a></li>
                <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-5" style="max-width: 680px;">
    <div class="card shadow border-0">
        <div class="card-header bg-success text-white">
            <h5 class="mb-0"><i class="bi bi-check-circle-fill me-2"></i>¡Estudiante registrado exitosamente!</h5>
        </div>
        <div class="card-body p-4">
            <p class="text-muted mb-4">Se han guardado los siguientes datos en el sistema:</p>

            <%-- ── Confirmación usando jsp:getProperty (requerimiento de rúbrica) ── --%>
            <table class="table table-bordered table-sm">
                <tbody>
                <tr>
                    <th class="bg-light" style="width:40%">Carnet</th>
                    <td>
                        <span class="badge bg-secondary fs-6">
                            <jsp:getProperty name="estudianteBean" property="carnet" />
                        </span>
                    </td>
                </tr>
                <tr>
                    <th class="bg-light">Nombre completo</th>
                    <td><jsp:getProperty name="estudianteBean" property="nombre_estudiante" /></td>
                </tr>
                <tr>
                    <th class="bg-light">Carrera</th>
                    <td><jsp:getProperty name="estudianteBean" property="carrera" /></td>
                </tr>
                <tr>
                    <th class="bg-light">Teléfono</th>
                    <td>
                        <%
                            String tel = estudianteBean.getTelefono();
                            out.print(tel != null && !tel.isEmpty() ? tel : "No proporcionado");
                        %>
                    </td>
                </tr>
                </tbody>
            </table>

            <div class="d-flex gap-2 mt-3">
                <a href="registroEstudiante.jsp" class="btn btn-success">
                    <i class="bi bi-plus-circle me-1"></i>Registrar otro estudiante
                </a>
                <a href="listaEstudiantes.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-people me-1"></i>Ver estudiantes
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
