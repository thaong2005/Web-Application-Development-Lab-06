<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .navbar h2 {
            font-size: 20px;
        }
        
        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .role-admin {
            background: #e74c3c;
        }
        
        .role-user {
            background: #3498db;
        }
        
        .btn-logout {
            padding: 8px 20px;
            background: #e74c3c;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-logout:hover {
            background: #c0392b;
        }
        
        .container {
            max-width: 600px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .page-header {
            background: white;
            padding: 25px 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .page-header h1 {
            color: #2c3e50;
            font-size: 24px;
            margin-bottom: 5px;
        }
        
        .page-header p {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .form-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #2c3e50;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #3498db;
        }
        
        .password-requirements {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 5px;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .alert-error {
            background: #fee;
            color: #c00;
            border: 1px solid #fcc;
        }
        
        .alert-success {
            background: #efe;
            color: #060;
            border: 1px solid #cfc;
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 25px;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-secondary {
            background: #95a5a6;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #3498db;
            text-decoration: none;
            font-size: 14px;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h2>📚 Student Management System</h2>
        <div class="navbar-right">
            <div class="user-info">
                <span>${sessionScope.fullName}</span>
                <span class="role-badge role-${sessionScope.role}">
                    ${sessionScope.role}
                </span>
            </div>
            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="container">
        <a href="dashboard" class="back-link">← Back to Dashboard</a>
        
        <!-- Page Header -->
        <div class="page-header">
            <h1>🔒 Change Password</h1>
            <p>Update your account password</p>
        </div>
        
        <!-- Change Password Form -->
        <div class="form-card">
            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    ❌ ${error}
                </div>
            </c:if>
            
            <!-- Success Message -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    ✅ ${success}
                </div>
            </c:if>
            
            <form action="change-password" method="post">
                <!-- Current Password -->
                <div class="form-group">
                    <label for="currentPassword">Current Password *</label>
                    <input type="password" 
                           id="currentPassword" 
                           name="currentPassword" 
                           placeholder="Enter your current password"
                           required>
                </div>
                
                <!-- New Password -->
                <div class="form-group">
                    <label for="newPassword">New Password *</label>
                    <input type="password" 
                           id="newPassword" 
                           name="newPassword" 
                           placeholder="Enter your new password"
                           required>
                    <div class="password-requirements">
                        Password must be at least 8 characters long
                    </div>
                </div>
                
                <!-- Confirm Password -->
                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password *</label>
                    <input type="password" 
                           id="confirmPassword" 
                           name="confirmPassword" 
                           placeholder="Confirm your new password"
                           required>
                </div>
                
                <!-- Buttons -->
                <div class="button-group">
                    <button type="submit" class="btn btn-primary">
                        Change Password
                    </button>
                    <a href="dashboard" class="btn btn-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Client-side validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            // Check minimum length
            if (newPassword.length < 8) {
                e.preventDefault();
                alert('New password must be at least 8 characters long');
                return;
            }
            
            // Check if passwords match
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('New password and confirm password do not match');
                return;
            }
        });
    </script>
</body>
</html>
