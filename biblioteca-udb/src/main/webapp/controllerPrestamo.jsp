<%-- ============================================================
     controllerPrestamo.jsp
     Controlador JSP para la gestión de préstamos.
     Acciones soportadas (parámetro "action"):
       - guardar  : Registra un nuevo préstamo y muestra confirmación
                    usando jsp:getProperty (requerimiento de rúbrica).
       - devolver : Marca el préstamo como Devuelto e incrementa stock.
     Si no hay action, redirige al formulario de nuevo préstamo.

     NOTA: En la acción "devolver", el formulario debe enviar:
       - id_prestamo  (campo hidden)
       - id_libro     (campo hidden)
     Ambos son mapeados automáticamente por jsp:setProperty property="*".
     ============================================================ --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.PrestamoBean, udb.biblioteca.EstudianteBean, udb.biblioteca.LibroBean" %>
<%@ page import="java.sql.SQLException" %>

<%-- ── 1. Incluir conexión centralizada (expone objeto "conn") ── --%>
<%@ include file="conexion.jsp" %>

<%-- ── 2. Instanciar y autorellenar el Bean desde los parámetros del request ──
         jsp:setProperty property="*" mapea automáticamente:
           id_estudiante → prestamoBean.setId_estudiante(int)
           id_libro      → prestamoBean.setId_libro(int)
           id_prestamo   → prestamoBean.setId_prestamo(int) (en devolución) --%>
<jsp:useBean id="prestamoBean" class="udb.biblioteca.PrestamoBean" scope="page" />
<jsp:setProperty name="prestamoBean" property="*" />

<%
    /* ── 3. Inyectar la conexión al bean para sus métodos de negocio ── */
    prestamoBean.setConn(conn);

    String  action  = request.getParameter("action");
    String  mensaje = null;
    boolean exito   = false;
    boolean error   = false;
    String  accionRealizada = "";

    /* ================================================================
       ACCIÓN: guardar — Nuevo préstamo
       ================================================================ */
    if ("guardar".equals(action)) {

        /* ── 4. Validación básica: los IDs deben ser > 0 ── */
        if (prestamoBean.getId_estudiante() <= 0 || prestamoBean.getId_libro() <= 0) {
            mensaje = "Debe seleccionar un estudiante y un libro válidos.";
            error   = true;
        } else {
            try {
                /*
                 * ── 5. Persistir el préstamo ──
                 * El método guardar() del Bean:
                 *   a) Valida que cantidad_disponible > 0 (lanza IllegalStateException si no).
                 *   b) Calcula fecha_prestamo = hoy y fecha_devolucion = hoy + 9 días.
                 *   c) Inserta en prestamos con estado 'Activo'.
                 *   d) Decrementa cantidad_disponible en libros en -1.
                 */
                prestamoBean.guardar();
                exito = true;
                accionRealizada = "guardar";

                /* Cargar datos completos del estudiante y libro para mostrar en confirmación */
                EstudianteBean eb = new EstudianteBean();
                EstudianteBean estEncontrado = eb.obtenerPorId(conn, prestamoBean.getId_estudiante());
                if (estEncontrado != null) prestamoBean.setEstudiante(estEncontrado);

                LibroBean lb = new LibroBean();
                LibroBean libEncontrado = lb.obtenerPorId(conn, prestamoBean.getId_libro());
                if (libEncontrado != null) prestamoBean.setLibro(libEncontrado);

                /* Recuperar las fechas recién insertadas desde la BD */
                String sqlFechas = "SELECT fecha_prestamo, fecha_devolucion FROM prestamos " +
                                   "WHERE id_estudiante=? AND id_libro=? ORDER BY id_prestamo DESC LIMIT 1";
                try (java.sql.PreparedStatement psFechas = conn.prepareStatement(sqlFechas)) {
                    psFechas.setInt(1, prestamoBean.getId_estudiante());
                    psFechas.setInt(2, prestamoBean.getId_libro());
                    try (java.sql.ResultSet rsFechas = psFechas.executeQuery()) {
                        if (rsFechas.next()) {
                            prestamoBean.setFecha_prestamo(rsFechas.getString("fecha_prestamo"));
                            prestamoBean.setFecha_devolucion(rsFechas.getString("fecha_devolucion"));
                        }
                    }
                }

            } catch (IllegalStateException e) {
                /* Sin stock disponible */
                mensaje = e.getMessage();
                error   = true;
            } catch (SQLException e) {
                mensaje = "Error de base de datos al registrar el préstamo: " + e.getMessage();
                error   = true;
            }
        }

    /* ================================================================
       ACCIÓN: devolver — Devolución de libro
       ================================================================ */
    } else if ("devolver".equals(action)) {

        /* ── 4. Validación: id_prestamo e id_libro deben ser > 0 ── */
        if (prestamoBean.getId_prestamo() <= 0 || prestamoBean.getId_libro() <= 0) {
            mensaje = "Datos de devolución inválidos. Intente nuevamente.";
            error   = true;
        } else {
            try {
                /*
                 * ── 5. Ejecutar devolución ──
                 * El método devolver() del Bean:
                 *   a) UPDATE prestamos SET estado = 'Devuelto' WHERE id_prestamo = ?
                 *   b) UPDATE libros SET cantidad_disponible = cantidad_disponible + 1 WHERE id_libro = ?
                 */
                prestamoBean.devolver();

                /* Post-Redirect-Get */
                if (conn != null && !conn.isClosed()) conn.close();
                response.sendRedirect("listaPrestamos.jsp?msg=devuelto");
                return;

            } catch (SQLException e) {
                mensaje = "Error de base de datos al registrar la devolución: " + e.getMessage();
                error   = true;
            }
        }
    }

    /* ── 6. Si hubo error en cualquier acción ── */
    if (error) {
        if (conn != null && !conn.isClosed()) conn.close();
        response.sendRedirect("registroPrestamo.jsp?error=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
        return;
    }

    /* ── 7. Acceso directo sin action ── */
    if (!exito) {
        if (conn != null && !conn.isClosed()) conn.close();
        response.sendRedirect("registroPrestamo.jsp");
        return;
    }
    /* Si llegamos aquí, exito=true y accionRealizada="guardar" → renderizar confirmación */
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Préstamo Registrado – Biblioteca UDB</title>
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
                <li class="nav-item"><a class="nav-link" href="registroEstudiante.jsp"><i class="bi bi-person-plus me-1"></i>Estudiantes</a></li>
                <li class="nav-item"><a class="nav-link active" href="registroPrestamo.jsp"><i class="bi bi-arrow-left-right me-1"></i>Préstamos</a></li>
                <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-5" style="max-width: 700px;">
    <div class="card shadow border-0">
        <div class="card-header bg-warning">
            <h5 class="mb-0 fw-bold"><i class="bi bi-check-circle-fill me-2"></i>¡Préstamo registrado exitosamente!</h5>
        </div>
        <div class="card-body p-4">
            <p class="text-muted mb-4">Resumen del préstamo registrado en el sistema:</p>

            <%-- ── Confirmación con jsp:getProperty (requerimiento de rúbrica) ── --%>
            <h6 class="fw-bold text-primary mb-2"><i class="bi bi-person me-1"></i>Datos del Estudiante</h6>
            <table class="table table-bordered table-sm mb-4">
                <tbody>
                <tr>
                    <th class="bg-light" style="width:40%">Nombre</th>
                    <td><%= prestamoBean.getEstudiante().getNombre_estudiante() %></td>
                </tr>
                <tr>
                    <th class="bg-light">Carnet</th>
                    <td><span class="badge bg-secondary"><%= prestamoBean.getEstudiante().getCarnet() %></span></td>
                </tr>
                <tr>
                    <th class="bg-light">Carrera</th>
                    <td><%= prestamoBean.getEstudiante().getCarrera() %></td>
                </tr>
                </tbody>
            </table>

            <h6 class="fw-bold text-primary mb-2"><i class="bi bi-journal-text me-1"></i>Datos del Libro</h6>
            <table class="table table-bordered table-sm mb-4">
                <tbody>
                <tr>
                    <th class="bg-light" style="width:40%">Título</th>
                    <td><%= prestamoBean.getLibro().getTitulo() %></td>
                </tr>
                <tr>
                    <th class="bg-light">Autor</th>
                    <td><%= prestamoBean.getLibro().getAutor() %></td>
                </tr>
                <tr>
                    <th class="bg-light">ISBN</th>
                    <td><%= prestamoBean.getLibro().getIsbn() != null ? prestamoBean.getLibro().getIsbn() : "N/A" %></td>
                </tr>
                </tbody>
            </table>

            <h6 class="fw-bold text-primary mb-2"><i class="bi bi-calendar me-1"></i>Datos del Préstamo</h6>
            <table class="table table-bordered table-sm mb-3">
                <tbody>
                <tr>
                    <th class="bg-light" style="width:40%">Fecha de préstamo</th>
                    <td><jsp:getProperty name="prestamoBean" property="fecha_prestamo" /></td>
                </tr>
                <tr>
                    <th class="bg-light">Fecha límite de devolución</th>
                    <td>
                        <span class="fw-semibold text-danger">
                            <jsp:getProperty name="prestamoBean" property="fecha_devolucion" />
                        </span>
                        <small class="text-muted ms-1">(+9 días)</small>
                    </td>
                </tr>
                <tr>
                    <th class="bg-light">Estado</th>
                    <td>
                        <span class="badge bg-success px-3">
                            <i class="bi bi-clock me-1"></i>Vigente
                        </span>
                    </td>
                </tr>
                </tbody>
            </table>

            <div class="d-flex gap-2 mt-3">
                <a href="registroPrestamo.jsp" class="btn btn-warning fw-semibold">
                    <i class="bi bi-plus-circle me-1"></i>Nuevo Préstamo
                </a>
                <a href="listaPrestamos.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-table me-1"></i>Ver todos los préstamos
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
