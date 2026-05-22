<%--
  Created by IntelliJ IDEA.
  User: USUARIO LENOVO
  Date: 21/5/2026
  Time: 16:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.EstudianteBean, udb.biblioteca.LibroBean, java.util.List" %>

<%-- ── Conexión e inyección para cargar los dos selects dinámicos ── --%>
<%@ include file="conexion.jsp" %>

<jsp:useBean id="estudianteBean" class="udb.biblioteca.EstudianteBean" scope="page" />
<jsp:useBean id="libroBean"      class="udb.biblioteca.LibroBean"      scope="page" />

<%
  estudianteBean.setConn(conn);
  libroBean.setConn(conn);

  List<EstudianteBean> estudiantes     = estudianteBean.getListaEstudiantes();
  List<LibroBean>      librosDisponibles = libroBean.getListaLibrosDisponibles();

  String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Registrar Préstamo – Biblioteca UDB</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
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
        <li class="nav-item"><a class="nav-link active" href="registroPrestamo.jsp"><i class="bi bi-arrow-left-right me-1"></i>Préstamos</a></li>
        <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
      </ul>
    </div>
  </div>
</nav>

<div class="container my-4" style="max-width: 680px;">
  <div class="card shadow-sm border-0">
    <div class="card-header bg-warning">
      <h5 class="mb-0 fw-bold"><i class="bi bi-arrow-left-right me-2"></i>Registrar Nuevo Préstamo</h5>
    </div>
    <div class="card-body p-4">

      <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>

      <div class="alert alert-info d-flex align-items-center py-2" role="alert">
        <i class="bi bi-info-circle-fill me-2"></i>
        <small>La fecha de préstamo es la de hoy. La devolución máxima se calculará a <strong>+9 días</strong> automáticamente.</small>
      </div>

      <%--
          Los name DEBEN coincidir con propiedades del PrestamoBean:
            id_estudiante → prestamoBean.setId_estudiante(int)
            id_libro      → prestamoBean.setId_libro(int)
      --%>
      <form action="controllerPrestamo.jsp?action=guardar" method="post">

        <%-- Select DINÁMICO: Estudiantes --%>
        <div class="mb-3">
          <label for="id_estudiante" class="form-label fw-semibold">
            Estudiante <span class="text-danger">*</span>
          </label>
          <select class="form-select" id="id_estudiante" name="id_estudiante" required>
            <option value="">— Seleccione un estudiante —</option>
            <% for (EstudianteBean est : estudiantes) { %>
            <option value="<%= est.getId_estudiante() %>">
              [<%= est.getCarnet() %>] <%= est.getNombre_estudiante() %> — <%= est.getCarrera() %>
            </option>
            <% } %>
          </select>
        </div>

        <%-- Select DINÁMICO: Libros con stock > 0 --%>
        <div class="mb-4">
          <label for="id_libro" class="form-label fw-semibold">
            Libro disponible <span class="text-danger">*</span>
          </label>
          <% if (librosDisponibles.isEmpty()) { %>
          <div class="alert alert-warning py-2 mb-0">
            <i class="bi bi-exclamation-triangle me-1"></i>
            No hay libros con ejemplares disponibles en este momento.
          </div>
          <% } else { %>
          <select class="form-select" id="id_libro" name="id_libro" required>
            <option value="">— Seleccione un libro —</option>
            <% for (LibroBean lib : librosDisponibles) { %>
            <option value="<%= lib.getId_libro() %>">
              <%= lib.getTitulo() %> — <%= lib.getAutor() %>
              (ISBN: <%= lib.getIsbn() != null ? lib.getIsbn() : "S/N" %> |
              Disponibles: <%= lib.getCantidad_disponible() %>)
            </option>
            <% } %>
          </select>
          <% } %>
        </div>

        <div class="d-grid gap-2 d-sm-flex justify-content-sm-end">
          <a href="index.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-x-circle me-1"></i>Cancelar
          </a>
          <button type="submit" class="btn btn-warning fw-semibold"
                  <%= librosDisponibles.isEmpty() ? "disabled" : "" %>>
            <i class="bi bi-save me-1"></i>Registrar Préstamo
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
