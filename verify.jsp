<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.ByteArrayOutputStream,java.io.InputStream,java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.HashSet,java.util.Locale,java.util.Set,java.util.regex.Matcher,java.util.regex.Pattern" %>
<%!
    private String encodeQuery(String value) throws java.io.UnsupportedEncodingException {
        return URLEncoder.encode(value, "UTF-8").replace("+", "%20");
    }

    private String readArticleText(jakarta.servlet.ServletContext context) throws java.io.IOException {
        try (InputStream input = context.getResourceAsStream("/about.html")) {
            if (input == null) {
                throw new IllegalStateException("about.html was not found in the deployed web application.");
            }
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[4096];
            int count;
            while ((count = input.read(buffer)) != -1) {
                output.write(buffer, 0, count);
            }
            String html = new String(output.toByteArray(), StandardCharsets.UTF_8);
            Matcher article = Pattern.compile("(?is)<article\\b[^>]*id\\s*=\\s*['\"]hibernate-content['\"][^>]*>(.*?)</article\\s*>").matcher(html);
            if (!article.find()) {
                throw new IllegalStateException("The Hibernate article could not be read from about.html.");
            }
            return article.group(1)
                          .replaceAll("(?is)<script\\b[^>]*>.*?</script\\s*>", " ")
                          .replaceAll("(?is)<style\\b[^>]*>.*?</style\\s*>", " ")
                          .replaceAll("(?s)<[^>]+>", " ")
                          .replaceAll("&[A-Za-z0-9#]+;", " ");
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    String userName = request.getParameter("userName");
    String email = request.getParameter("email");
    String summary = request.getParameter("summary");
    userName = userName == null ? "" : userName.trim();
    email = email == null ? "" : email.trim();
    summary = summary == null ? "" : summary.trim();

    String error = null;
    if (userName.length() != 10) {
        error = "Your name must be exactly 10 characters long.";
    } else if (userName.isEmpty() || !Character.isUpperCase(userName.codePointAt(0))) {
        error = "Your name must start with a capital letter.";
    } else if (email.length() <= "@gmail.com".length() || !email.toLowerCase(Locale.ROOT).endsWith("@gmail.com")) {
        error = "Please enter an email address ending in @gmail.com.";
    } else if (summary.isEmpty()) {
        error = "Please enter a summary before submitting.";
    }

    if (error != null) {
        String destination = request.getContextPath() + "/test.html?error=" + encodeQuery(error);
        response.sendRedirect(response.encodeRedirectURL(destination));
        return;
    }

    String articleText = readArticleText(application);
    Set<String> articleWords = new HashSet<String>();
    Matcher articleMatcher = Pattern.compile("[\\p{L}\\p{N}]+").matcher(articleText.toLowerCase(Locale.ROOT));
    while (articleMatcher.find()) {
        articleWords.add(articleMatcher.group());
    }

    int totalWords = 0;
    int matchedWords = 0;
    Matcher summaryMatcher = Pattern.compile("[\\p{L}\\p{N}]+").matcher(summary.toLowerCase(Locale.ROOT));
    while (summaryMatcher.find()) {
        totalWords++;
        if (articleWords.contains(summaryMatcher.group())) {
            matchedWords++;
        }
    }
    int score = totalWords == 0 ? 0 : (int) Math.round(matchedWords * 100.0 / totalWords);
    String destination = request.getContextPath() + "/result.jsp?name=" + encodeQuery(userName)
            + "&score=" + score
            + "&matched=" + matchedWords
            + "&total=" + totalWords;
    response.sendRedirect(response.encodeRedirectURL(destination));
%>
