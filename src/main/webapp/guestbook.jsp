<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.example.guestbook.Greeting" %>
<%@ page import="com.example.guestbook.Guestbook" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
%>

<div class="header">
    <div class="left"><h1>Salut, ${fn:escapeXml(user.nickname)}!</h1></div>
    <div class="right"><a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">se déconnecter</a></div>
</div>

<div class="content">
<h1>Dépose une annonce ci-dessous:</h1>

<form action="/sign" method="post">
    <div><label for="titre">Titre: </label><input type="text" name="titre"/></div>
    <div><label for="description">Description: </label><textarea name="description" rows="3" cols="60"></textarea></div>
    <div><label for="prix">Prix(€): </label><input type="text" name="prix"/></div>
    <div><input type="submit" value="Publier"/></div>
    <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
</form>
</div>
<%
} else {
%>
<div class="header">
</div>
<div class="content">
<h1>Salut !
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Connecte-toi</a>
    pour déposer une annonce.
</h1>
</div>
<%
    }
%>
<div class="annonces">
<%
    // Create the correct Ancestor key
      Key<Guestbook> theBook = Key.create(Guestbook.class, guestbookName);

    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
      List<Greeting> greetings = ObjectifyService.ofy()
          .load()
          .type(Greeting.class) // We want only Greetings
          .ancestor(theBook)    // Anyone in this book
          .order("-date")       // Most recent first - date is indexed.
          .limit(5)             // Only show 5 of them.
          .list();

    if (greetings.isEmpty()) {
%>
<p>Aucune annonce n'a été déposée!</p>
<%
    } else {
%>
<h1>Annonces déposées:</h1>
<ul class="annonces_list">

<%
      // Look at all of our greetings
        for (Greeting greeting : greetings) {
            pageContext.setAttribute("greeting_title", greeting.titre);
            pageContext.setAttribute("greeting_description", greeting.description);
            pageContext.setAttribute("greeting_price", greeting.prix);
            String author;
                author = greeting.author_email;
                String author_id = greeting.author_id;
                if (user != null && user.getUserId().equals(author_id)) {
                    author += " (You)";
                }
            pageContext.setAttribute("greeting_user", author);
%>
<li class="annonce">
    <h2>${fn:escapeXml(greeting_title)}</h2>
    <div class="user">déposée par ${fn:escapeXml(greeting_user)}</div>
    <h2>${fn:escapeXml(greeting_price)} €</h2>
    <div class="description">${fn:escapeXml(greeting_description)}</div>
</li>
<%
        }
%>
</ul>
<%
    }
%>
</div>
</body>
</html>