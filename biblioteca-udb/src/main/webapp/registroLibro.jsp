<%--
  Created by IntelliJ IDEA.
  User: USUARIO LENOVO
  Date: 21/5/2026
  Time: 16:21
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.CategoriaBean, java.util.List" %>

<%-- ── Conexión e inyección para cargar el select dinámico ── --%>
<%@ include file="conexion.jsp" %>
<jsp:useBean id="categoriaBean" class="udb.biblioteca.CategoriaBean" scope="page" />
<%
  categoriaBean.setConn(conn);
  List<CategoriaBean> categorias = categoriaBean.getListaCategorias();

  /* Mensaje de error enviado por el controlador vía redirect */
  String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Registrar Libro – Biblioteca UDB</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-light">

<%-- ── Navbar ── --%>
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
        <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
      </ul>
    </div>
  </div>
</nav>

<div class="container my-4" style="max-width: 680px;">
  <div class="card shadow-sm border-0">
    <div class="card-header bg-primary text-white">
      <h5 class="mb-0"><i class="bi bi-journal-plus me-2"></i>Registrar Nuevo Libro</h5>
    </div>
    <div class="card-body p-4">

      <%-- Alerta de error --%>
      <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>

      <%--
          CRÍTICO: action apunta al controllerLibro.jsp con action=guardar.
          Los name de los inputs DEBEN coincidir exactamente con las
          propiedades del LibroBean para que jsp:setProperty property="*" funcione.
      --%>
      <form action="controllerLibro.jsp?action=guardar" method="post">

        <div class="mb-3">
          <label for="titulo" class="form-label fw-semibold">Título <span class="text-danger">*</span></label>
          <input type="text" class="form-control" id="titulo"
                 name="titulo" placeholder="Ej: Ingeniería de Software" required>
        </div>

        <div class="mb-3">
          <label for="autor" class="form-label fw-semibold">Autor <span class="text-danger">*</span></label>
          <input type="text" class="form-control" id="autor"
                 name="autor" placeholder="Ej: Ian Sommerville" required>
        </div>

        <div class="mb-3">
          <label for="isbn" class="form-label fw-semibold">ISBN</label>
          <input type="text" class="form-control" id="isbn"
                 name="isbn" placeholder="Ej: 978-0137035151">
        </div>

        <%-- Select DINÁMICO de categorías — llena con getListaCategorias() --%>
        <div class="mb-3">
          <label for="id_categoria" class="form-label fw-semibold">Categoría <span class="text-danger">*</span></label>
          <select class="form-select" id="id_categoria" name="id_categoria" required>
            <option value="">— Seleccione una categoría —</option>
            <% for (CategoriaBean cat : categorias) { %>
            <option value="<%= cat.getId_categoria() %>">
              <%= cat.getNombre_categoria() %>
            </option>
            <% } %>
          </select>
        </div>

        <div class="mb-4">
          <label for="cantidad_disponible" class="form-label fw-semibold">Cantidad disponible</label>
          <input type="number" class="form-control" id="cantidad_disponible"
                 name="cantidad_disponible" min="1" value="1">
        </div>

        <div class="d-grid gap-2 d-sm-flex justify-content-sm-end">
          <a href="index.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-x-circle me-1"></i>Cancelar
          </a>
          <button type="submit" class="btn btn-primary">
            <i class="bi bi-save me-1"></i>Guardar Libro
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
