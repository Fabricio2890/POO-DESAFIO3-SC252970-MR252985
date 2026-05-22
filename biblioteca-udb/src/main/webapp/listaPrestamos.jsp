<%--
  Created by IntelliJ IDEA.
  User: USUARIO LENOVO
  Date: 21/5/2026
  Time: 16:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.PrestamoBean, java.util.List" %>

<%-- ── Conexión e inyección para cargar la lista completa ── --%>
<%@ include file="conexion.jsp" %>

<jsp:useBean id="prestamoBean" class="udb.biblioteca.PrestamoBean" scope="page" />
<%
  prestamoBean.setConn(conn);
  List<PrestamoBean> listaPrestamos = prestamoBean.getListaPrestamos();

  /* Mensajes de confirmación enviados por el controlador vía redirect */
  String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Lista de Préstamos – Biblioteca UDB</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
  <style>
    .table thead th { background-color: #0d6efd; color: white; white-space: nowrap; }
    .badge-vigente  { background-color: #198754; }
    .badge-vencido  { background-color: #dc3545; }
    .badge-devuelto { background-color: #6c757d; }
  </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container">
    <a class="navbar-brand fw-bold" href="index.jsp"><i class="bi bi-book-half me-2"></i>Biblioteca UDB</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="bi bi-journal-richtext me-1"></i>Libros</a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="registroLibro.jsp"><i class="bi bi-plus-circle me-1"></i>Registrar Libro</a></li>
                        <li><a class="dropdown-item" href="listaLibros.jsp"><i class="bi bi-list-ul me-1"></i>Ver Catálogo</a></li>
                    </ul>
                </li>
        <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="bi bi-people me-1"></i>Estudiantes</a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="registroEstudiante.jsp"><i class="bi bi-plus-circle me-1"></i>Registrar Estudiante</a></li>
                        <li><a class="dropdown-item" href="listaEstudiantes.jsp"><i class="bi bi-list-ul me-1"></i>Ver Estudiantes</a></li>
                    </ul>
                </li>
        <li class="nav-item"><a class="nav-link" href="registroPrestamo.jsp"><i class="bi bi-arrow-left-right me-1"></i>Préstamos</a></li>
        <li class="nav-item"><a class="nav-link active" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
      </ul>
    </div>
  </div>
</nav>

<div class="container-fluid my-4 px-4">

  <%-- Alertas de confirmación --%>
  <% if ("ok".equals(msg)) { %>
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i>Préstamo registrado exitosamente.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% } else if ("devuelto".equals(msg)) { %>
  <div class="alert alert-info alert-dismissible fade show" role="alert">
    <i class="bi bi-arrow-return-left me-2"></i>Libro marcado como devuelto. El stock ha sido actualizado.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% } %>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0 fw-bold"><i class="bi bi-table me-2"></i>Control de Préstamos</h4>
    <a href="registroPrestamo.jsp" class="btn btn-warning btn-sm">
      <i class="bi bi-plus-circle me-1"></i>Nuevo Préstamo
    </a>
  </div>

  <div class="card shadow-sm border-0">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover table-bordered mb-0 align-middle">
          <thead>
          <tr>
            <th class="text-center">#</th>
            <th>Estudiante</th>
            <th>Libro</th>
            <th class="text-center">F. Préstamo</th>
            <th class="text-center">F. Devolución</th>
            <th class="text-center">Estado</th>
            <th class="text-center">Acción</th>
          </tr>
          </thead>
          <tbody>
          <% if (listaPrestamos.isEmpty()) { %>
          <tr>
            <td colspan="7" class="text-center text-muted py-4">
              <i class="bi bi-inbox fs-4 d-block mb-1"></i>
              No hay préstamos registrados aún.
            </td>
          </tr>
          <% } else {
            for (PrestamoBean p : listaPrestamos) {
              String estadoCalculado = p.getEstadoPrestamo();
              String badgeClass = "badge-devuelto";
              String icono      = "bi-check-circle";
              if ("Vigente".equals(estadoCalculado)) {
                badgeClass = "badge-vigente";
                icono      = "bi-clock";
              } else if ("Vencido".equals(estadoCalculado)) {
                badgeClass = "badge-vencido";
                icono      = "bi-exclamation-circle";
              }
          %>
          <tr>
            <%-- ID --%>
            <td class="text-center fw-bold"><%= p.getId_prestamo() %></td>

            <%-- Estudiante --%>
            <td>
              <span class="fw-semibold"><%= p.getEstudiante().getNombre_estudiante() %></span>
              <br>
              <small class="text-muted"><%= p.getEstudiante().getCarnet() %> — <%= p.getEstudiante().getCarrera() %></small>
            </td>

            <%-- Libro --%>
            <td>
              <span class="fw-semibold"><%= p.getLibro().getTitulo() %></span>
              <br>
              <small class="text-muted"><%= p.getLibro().getAutor() %></small>
            </td>

            <%-- Fecha préstamo --%>
            <td class="text-center"><%= p.getFecha_prestamo() %></td>

            <%-- Fecha devolución --%>
            <td class="text-center"><%= p.getFecha_devolucion() %></td>

            <%-- Badge de estado calculado --%>
            <td class="text-center">
                                <span class="badge <%= badgeClass %> fs-6 px-3 py-1">
                                    <i class="bi <%= icono %> me-1"></i><%= estadoCalculado %>
                                </span>
            </td>

            <%-- Botón "Marcar como Devuelto" solo si el estado en BD es 'Activo' --%>
            <td class="text-center">
              <% if ("Activo".equals(p.getEstado())) { %>
              <%--
                  Formulario mini de devolución.
                  Envía id_prestamo e id_libro como hidden para que
                  jsp:setProperty property="*" los mapee automáticamente
                  al PrestamoBean en el controlador.
              --%>
              <form action="controllerPrestamo.jsp" method="post"
                    onsubmit="return confirm('¿Confirmar la devolución de este libro?');"
                    class="d-inline">
                <input type="hidden" name="action"      value="devolver">
                <input type="hidden" name="id_prestamo" value="<%= p.getId_prestamo() %>">
                <input type="hidden" name="id_libro"    value="<%= p.getId_libro() %>">
                <button type="submit" class="btn btn-sm btn-outline-success">
                  <i class="bi bi-arrow-return-left me-1"></i>Devolver
                </button>
              </form>
              <% } else { %>
              <span class="text-muted small">—</span>
              <% } %>
            </td>
          </tr>
          <%  }
          } %>
          </tbody>
        </table>
      </div>
    </div>
    <div class="card-footer text-muted small">
      Total de registros: <strong><%= listaPrestamos.size() %></strong>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
