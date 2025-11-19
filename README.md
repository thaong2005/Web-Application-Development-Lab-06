# Web-Application-Development-Lab-06
AUTHENTICATION &amp; SESSION MANAGEMENT

# Nguyễn Việt Thảo - ITCSIU23058 

## Explain Login flow


1. User accesses `GET /login` → `LoginController.doGet` returns `views/login.jsp`.
2. User submits form → `POST /login` → `LoginController.doPost` gets `username`/`password`.
3. `LoginController` calls `UserDAO.authenticate(username, password)`:
- Query user (only `is_active = TRUE`).
- Compare password with `BCrypt.checkpw(plain, hashed)`.
4. If authentication fails → forward to `login.jsp` with `error`.
5. If authentication succeeds:
- Invalidate old session (prevent session fixation).
- Create new session: `session = request.getSession(true)`. 
- Save information into session: 
- `session.setAttribute("user", user)` 
- `session.setAttribute("role", user.getRole())` 
- `session.setAttribute("fullName", user.getFullName())` 
- `session.setMaxInactiveInterval(30 * 60)` (30 minutes). 
- Redirect: admin → `/dashboard`, user → `/student?action=list`.
6. Then, `AuthFilter` checks `session.getAttribute("user")` for requests, if null → redirect `/login`.
7. `AdminFilter` protects admin actions (e.g. `new`, `insert`, `edit`, `update`, `delete`) by checking `user.isAdmin()`.

#### Demo code

`LoginController` (rút gọn):
```java
User user = userDAO.authenticate(username, password);
if (user != null) {
	HttpSession old = request.getSession(false);
	if (old != null) old.invalidate();

	HttpSession session = request.getSession(true);
	session.setAttribute("user", user);
	session.setAttribute("role", user.getRole());
	session.setAttribute("fullName", user.getFullName());
	session.setMaxInactiveInterval(30 * 60);

	if (user.isAdmin()) response.sendRedirect("dashboard");
	else response.sendRedirect("student?action=list");
} else {
	request.setAttribute("error", "Invalid username or password");
	request.getRequestDispatcher("/views/login.jsp").forward(request, response);
}
```

`UserDAO.authenticate`:
```java
PreparedStatement p = conn.prepareStatement(SQL_AUTHENTICATE);
p.setString(1, username);
ResultSet rs = p.executeQuery();
if (rs.next()) {
	String hashed = rs.getString("password");
	if (BCrypt.checkpw(password, hashed)) {
		user = mapResultSetToUser(rs);
		updateLastLogin(user.getId());
	}
}
```

`AuthFilter`:
```java
HttpSession session = httpRequest.getSession(false);
boolean loggedIn = (session != null && session.getAttribute("user") != null);
if (!loggedIn) httpResponse.sendRedirect(contextPath + "/login");
else chain.doFilter(request, response);
```

`AdminFilter`:
```java
String action = httpRequest.getParameter("action");
if (isAdminAction(action)) {
	User user = (User) session.getAttribute("user");
	if (user == null || !user.isAdmin()) {
		httpResponse.sendRedirect(contextPath + "/student?action=list&error=Access denied.");
		return;
	}
}
```


