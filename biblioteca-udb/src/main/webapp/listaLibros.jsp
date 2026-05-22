<%--
    listaLibros.jsp
    Página que muestra todos los libros del catálogo de la Biblioteca UDB.
    Paquete: udb.biblioteca | Asignatura: POO404 - Universidad Don Bosco
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.LibroBean, java.util.List" %>

<%-- ── Conexión e inyección para cargar la lista ── --%>
<%@ include file="conexion.jsp" %>

<jsp:useBean id="libroBean" class="udb.biblioteca.LibroBean" scope="page" />
<%
    libroBean.setConn(conn);
    List<LibroBean> listaLibros = libroBean.getListaLibros();
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catálogo de Libros – Biblioteca UDB</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .table thead th { background-color: #0d6efd; color: white; white-space: nowrap; }
        .badge-disponible { background-color: #198754; }
        .badge-agotado    { background-color: #dc3545; }
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
                <li class="nav-item"><a class="nav-link" href="listaPrestamos.jsp"><i class="bi bi-table me-1"></i>Ver Préstamos</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container-fluid my-4 px-4">

    <%-- Alerta de confirmación --%>
    <% if ("ok".equals(msg)) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>Libro registrado exitosamente en el catálogo.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0 fw-bold"><i class="bi bi-journal-richtext me-2"></i>Catálogo de Libros</h4>
        <a href="registroLibro.jsp" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-circle me-1"></i>Nuevo Libro
        </a>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered mb-0 align-middle">
                    <thead>
                    <tr>
                        <th class="text-center">#</th>
                        <th>Título</th>
                        <th>Autor</th>
                        <th class="text-center">ISBN</th>
                        <th>Categoría</th>
                        <th class="text-center">Disponibles</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (listaLibros.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">
                            <i class="bi bi-inbox fs-4 d-block mb-1"></i>
                            No hay libros registrados en el catálogo aún.
                        </td>
                    </tr>
                    <% } else {
                        for (LibroBean l : listaLibros) {
                            String badgeStock = l.isDisponible() ? "badge-disponible" : "badge-agotado";
                            String iconoStock = l.isDisponible() ? "bi-check-circle" : "bi-x-circle";
                    %>
                    <tr>
                        <td class="text-center fw-bold"><%= l.getId_libro() %></td>
                        <td><span class="fw-semibold"><%= l.getTitulo() %></span></td>
                        <td><%= l.getAutor() %></td>
                        <td class="text-center">
                            <small><%= l.getIsbn() != null ? l.getIsbn() : "—" %></small>
                        </td>
                        <td>
                            <span class="badge bg-secondary">
                                <%= l.getNombreCategoria().isEmpty() ? "Sin categoría" : l.getNombreCategoria() %>
                            </span>
                        </td>
                        <td class="text-center">
                            <span class="badge <%= badgeStock %> px-3">
                                <i class="bi <%= iconoStock %> me-1"></i><%= l.getCantidad_disponible() %>
                            </span>
                        </td>
                    </tr>
                    <%  }
                    } %>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="card-footer text-muted small">
            Total en catálogo: <strong><%= listaLibros.size() %></strong>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
