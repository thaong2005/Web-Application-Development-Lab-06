# Web-Application-Development-Lab-06
AUTHENTICATION &amp; SESSION MANAGEMENT

# Nguyễn Việt Thảo - ITCSIU23058 

# Login Flow:

1. Access: http://localhost:8080/YourApp/
Redirected to login (handled by `AuthFilter`).
``` java
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
```

AuthFilter detect public url. If user is not logged in, redirect to login.

``` java
if (isLoggedIn) {
    // User is logged in, allow access
    chain.doFilter(request, response);
} else {
    // User not logged in, redirect to login
    String loginURL = contextPath + "/login";
    httpResponse.sendRedirect(loginURL);
}
```
![Access screenshot](./output/loginflow/access.png)

2. Login with admin account: `admin / password123`
- After click “login” button, the login page with send request method `POST` to `LoginController.java`

- `LoginController` get parameter and call `dao.UserDAO.autthenticate(username, password)`

```java
public User authenticate(String username, String password) {
    User user = null;
        
    try (Connection conn = getConnection();
        PreparedStatement pstmt = conn.prepareStatement(SQL_AUTHENTICATE)) {
            
        pstmt.setString(1, username);
            
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                
                // Verify password with BCrypt
                if (BCrypt.checkpw(password, hashedPassword)) {
                    user = mapResultSetToUser(rs);
                        
                    // Update last login time
                    updateLastLogin(user.getId());
                }
            }
        }
            
    } catch (SQLException e) {
        e.printStackTrace();
    }
        
    return user;
}
```
- On success, old session will be invalidate to prevent session fixation in `LoginController.java`

```java
// Invalidate old session (prevent session fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
```

- Create new session
```java
// Create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("fullName", user.getFullName());
```

- `LoginController` check if the user is admin. If yes, Redirect to dashboard or student list
```java
// Redirect based on role
            if (user.isAdmin()) {
                response.sendRedirect("dashboard");
            } else {
                response.sendRedirect("student?action=list");
            }
```
![Admin login screenshot](./output/loginflow/loginAdmin.png)

3. Click "View All Students"
- Point to `student?action=list`
- `StudentController.java` read `student?action=list` and call `listStudents(…)`
- `StudentController.java` use StudentDAO to fetch students and forward to `student-list.jsp`

```java
 // Validate server-side
        if (!validateStudent(newStudent, request)) {
            // Preserve entered data and forward back to form
            request.setAttribute("student", newStudent);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
            dispatcher.forward(request, response);
            return;
        }
```
- `student-list.jsp` check  `<c:if test="${sessionScope.role eq 'admin'}">` and show the admin-only(add/ edit/ delete) button.
![View students screenshot](./output/loginflow/clickView.png)


4. Logout
- User click “log out” button (<a href="logout" class="btn-logout">Logout</a>)
-> direct to `LogoutController.java`

- `LogoutController` invalidate the current session
```java
if (session != null) {
    // Invalidate session
    session.invalidate();
}
```
- Redirect to login.jsp
```java 
	// Redirect to login page with message
    response.sendRedirect("login?message=You have been logged out successfully");
```
![Logout screenshot](./output/loginflow/logout.png)

5. Login with student account: `john / password123`
- After click “login” button, the login page with send request method “POST” to `LoginController.java`
- `LoginController` get parameter and call `UserDAO.authenticate(username, password)`
```java
public User authenticate(String username, String password) {
    User user = null;
        
    try (Connection conn = getConnection();
        PreparedStatement pstmt = conn.prepareStatement(SQL_AUTHENTICATE)) {
            
        pstmt.setString(1, username);
            
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                
                // Verify password with BCrypt
                if (BCrypt.checkpw(password, hashedPassword)) {
                    user = mapResultSetToUser(rs);
                        
                    // Update last login time
                    updateLastLogin(user.getId());
                }
            }
        }
            
    } catch (SQLException e) {
        e.printStackTrace();
    }
        
    return user;
}
```
- On success, old session will be invalidate to prevent session fixation in `LoginController.java`

```java
// Invalidate old session (prevent session fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
```

- Create new session
```java
// Create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("fullName", user.getFullName());
```

- `LoginController` check if the user is student. If yes, Redirect to `student-list.jsp`
```java
// Redirect based on role
            if (user.isAdmin()) {
                response.sendRedirect("dashboard");
            } else {
                response.sendRedirect("student?action=list");
            }
```
- `student-list.jsp` check sessionScope.role >< admin -> hide add/edit/delete button.
![Student login screenshot](./output/loginflow/loginStudent.png)

6. Try to access: `/student?action=new`
- `AdminFilter.java` run through ```@WebFilter(filterName = "AdminFilter", urlPatterns = {"/student"})```
- `AdminFilter.java` get the request and check if the logged user are admin or not. Since the user are not the admin. AdminFilter redirect back to `student-list.jsp` and show error log
```java
	if (user != null && user.isAdmin()) {
    // User is admin, allow access
    chain.doFilter(request, response);
    } else {
    // User is not admin, deny access
    httpResponse.sendRedirect(httpRequest.getContextPath() + 
    "/student?action=list&error=Access denied. Admin privileges required.");
	}
```
![Admin action blocked screenshot](./output/loginflow/studentAdd.png)

