package com.student.controller;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import com.student.dao.UserDAO;
import com.student.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/change-password")
public class ChangePasswordController extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    /**
     * Display change password form
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        // Show change password form
        request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
    }
    
    /**
     * Process change password form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get current user from session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        
        // Get form parameters
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input - check for null or empty
        if (currentPassword == null || currentPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
            return;
        }
        
        // Validate current password
        if (!BCrypt.checkpw(currentPassword, currentUser.getPassword())) {
            request.setAttribute("error", "Current password is incorrect");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
            return;
        }
        
        // Validate new password length (minimum 8 characters)
        if (newPassword.length() < 8) {
            request.setAttribute("error", "New password must be at least 8 characters long");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
            return;
        }
        
        // Validate new password matches confirm password
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirm password do not match");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
            return;
        }
        
        // Check if new password is same as current password
        if (currentPassword.equals(newPassword)) {
            request.setAttribute("error", "New password must be different from current password");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
            return;
        }
        
        // Hash new password
        String newHashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        
        // Update password in database
        boolean updateSuccess = userDAO.updatePassword(currentUser.getId(), newHashedPassword);
        
        if (updateSuccess) {
            // Update user object in session with new password
            currentUser.setPassword(newHashedPassword);
            session.setAttribute("user", currentUser);
            
            // Show success message
            request.setAttribute("success", "Password changed successfully!");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
        } else {
            // Show error message
            request.setAttribute("error", "Failed to update password. Please try again.");
            request.getRequestDispatcher("/views/change-password.jsp").forward(request, response);
        }
    }
}
