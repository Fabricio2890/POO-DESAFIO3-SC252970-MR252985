<%--
    listaEstudiantes.jsp
    Página que muestra todos los estudiantes registrados en el sistema.
    Paquete: udb.biblioteca | Asignatura: POO404 - Universidad Don Bosco
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="udb.biblioteca.EstudianteBean, java.util.List" %>

<%-- ── Conexión e inyección para cargar la lista ── --%>
<%@ include file="conexion.jsp" %>

<jsp:useBean id="estudianteBean" class="udb.biblioteca.EstudianteBean" scope="page" />
<%
    estudianteBean.setConn(conn);
    List<EstudianteBean> listaEstudiantes = estudianteBean.getListaEstudiantes();
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lista de Estudiantes – Biblioteca UDB</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .table thead th { background-color: #198754; color: white; white-space: nowrap; }
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
        <i class="bi bi-check-circle-fill me-2"></i>Estudiante registrado exitosamente.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0 fw-bold"><i class="bi bi-people me-2"></i>Estudiantes Registrados</h4>
        <a href="registroEstudiante.jsp" class="btn btn-success btn-sm">
            <i class="bi bi-plus-circle me-1"></i>Nuevo Estudiante
        </a>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered mb-0 align-middle">
                    <thead>
                    <tr>
                        <th class="text-center">#</th>
                        <th>Carnet</th>
                        <th>Nombre</th>
                        <th>Carrera</th>
                        <th class="text-center">Teléfono</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (listaEstudiantes.isEmpty()) { %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">
                            <i class="bi bi-inbox fs-4 d-block mb-1"></i>
                            No hay estudiantes registrados aún.
                        </td>
                    </tr>
                    <% } else {
                        for (EstudianteBean e : listaEstudiantes) { %>
                    <tr>
                        <td class="text-center fw-bold"><%= e.getId_estudiante() %></td>
                        <td><span class="badge bg-secondary"><%= e.getCarnet() %></span></td>
                        <td><span class="fw-semibold"><%= e.getNombre_estudiante() %></span></td>
                        <td><%= e.getCarrera() %></td>
                        <td class="text-center">
                            <% if (e.getTelefono() != null && !e.getTelefono().isEmpty()) { %>
                            <i class="bi bi-telephone me-1 text-muted"></i><%= e.getTelefono() %>
                            <% } else { %>
                            <span class="text-muted">—</span>
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
            Total de estudiantes: <strong><%= listaEstudiantes.size() %></strong>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
