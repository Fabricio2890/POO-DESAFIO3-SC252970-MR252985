<%--
  Created by IntelliJ IDEA.
  User: USUARIO LENOVO
  Date: 21/5/2026
  Time: 16:19
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Biblioteca UDB - Sistema de Préstamos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        .card-icono { font-size: 2.5rem; }
        .hero { background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
            color: white; padding: 3rem 1rem; border-radius: 0 0 1rem 1rem; }
    </style>
</head>
<body>

<%-- ── Navbar ── --%>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">
            <i class="bi bi-book-half me-2"></i>Biblioteca UDB
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
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
                <li class="nav-item">
                    <a class="nav-link" href="registroPrestamo.jsp">
                        <i class="bi bi-arrow-left-right me-1"></i>Préstamos
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="listaPrestamos.jsp">
                        <i class="bi bi-table me-1"></i>Ver Préstamos
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<%-- ── Hero ── --%>
<div class="hero text-center mb-4">
    <h1 class="display-5 fw-bold"><i class="bi bi-building me-2"></i>Biblioteca Central</h1>
    <p class="lead mb-0">Universidad Don Bosco — Sistema de Control de Préstamos</p>
</div>

<%-- ── Tarjetas de acceso rápido ── --%>
<div class="container mb-5">
    <div class="row g-4 justify-content-center">

        <div class="col-md-4">
            <div class="card h-100 shadow-sm border-0 text-center">
                <div class="card-body py-4">
                    <div class="card-icono text-primary mb-3"><i class="bi bi-journal-plus"></i></div>
                    <h5 class="card-title fw-bold">Registrar Libro</h5>
                    <p class="card-text text-muted">Agrega un nuevo ejemplar al catálogo de la biblioteca.</p>
                    <a href="registroLibro.jsp" class="btn btn-primary">
                        <i class="bi bi-plus-circle me-1"></i>Nuevo Libro
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card h-100 shadow-sm border-0 text-center">
                <div class="card-body py-4">
                    <div class="card-icono text-success mb-3"><i class="bi bi-person-plus"></i></div>
                    <h5 class="card-title fw-bold">Registrar Estudiante</h5>
                    <p class="card-text text-muted">Inscribe un nuevo estudiante en el sistema de la biblioteca.</p>
                    <a href="registroEstudiante.jsp" class="btn btn-success">
                        <i class="bi bi-plus-circle me-1"></i>Nuevo Estudiante
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card h-100 shadow-sm border-0 text-center">
                <div class="card-body py-4">
                    <div class="card-icono text-warning mb-3"><i class="bi bi-arrow-left-right"></i></div>
                    <h5 class="card-title fw-bold">Nuevo Préstamo</h5>
                    <p class="card-text text-muted">Registra la salida de un libro para un estudiante.</p>
                    <a href="registroPrestamo.jsp" class="btn btn-warning">
                        <i class="bi bi-plus-circle me-1"></i>Nuevo Préstamo
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card h-100 shadow-sm border-0 text-center">
                <div class="card-body py-4">
                    <div class="card-icono text-info mb-3"><i class="bi bi-table"></i></div>
                    <h5 class="card-title fw-bold">Control de Préstamos</h5>
                    <p class="card-text text-muted">Consulta todos los préstamos activos, vencidos y devueltos.</p>
                    <a href="listaPrestamos.jsp" class="btn btn-info text-white">
                        <i class="bi bi-eye me-1"></i>Ver Lista
                    </a>
                </div>
            </div>
        </div>

    </div>
</div>

<footer class="text-center text-muted py-3 border-top">
    <small>POO404 &mdash; Universidad Don Bosco &copy; 2025</small>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
