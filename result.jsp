<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String escapeHtml(String value) {
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
<%
    String userName = request.getParameter("name");
    String scoreParameter = request.getParameter("score");
    String matchedParameter = request.getParameter("matched");
    String totalParameter = request.getParameter("total");
    int score = -1;
    int matched = -1;
    int total = -1;
    try {
        score = Integer.parseInt(scoreParameter);
        matched = Integer.parseInt(matchedParameter);
        total = Integer.parseInt(totalParameter);
    } catch (NumberFormatException | NullPointerException ignored) {
        // Show the missing-result state below when the result URL has no valid score.
    }
    boolean validResult = userName != null && !userName.isEmpty()
            && score >= 0 && score <= 100
            && matched >= 0 && total >= matched;
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Your Result | Hibernate Learning Lab</title>
  <link rel="stylesheet" href="styles.css">
  <style>
    .result-wrap{max-width:760px;margin:0 auto;padding:92px 24px 110px}.result-card{padding:54px 48px;text-align:center;background:#fff;border:1px solid var(--line);border-radius:18px;box-shadow:var(--shadow)}.score-ring{width:154px;height:154px;margin:24px auto;display:grid;place-content:center;border:8px solid #e6f2ed;border-right-color:var(--green);border-bottom-color:var(--green);border-radius:50%;transform:rotate(-45deg)}.score-inner{transform:rotate(45deg)}.score-value{display:block;font:800 43px/1 Manrope,sans-serif;letter-spacing:-.06em}.score-unit{display:block;margin-top:7px;color:var(--muted);font-size:11px}.result-card h1{margin:0;font:800 36px/1.2 Manrope,sans-serif;letter-spacing:-.05em}.result-card h1 span{color:var(--green)}.result-copy{max-width:460px;margin:14px auto 22px;color:var(--muted);font-size:14px}.match-count{margin:0 0 27px;color:#667875;font-size:12px}.result-actions{display:flex;justify-content:center;gap:12px;flex-wrap:wrap}.button-secondary{border:1px solid var(--line);background:#fff;color:var(--green)}.error-card{max-width:650px;margin:100px auto;padding:36px;background:white;border:1px solid var(--line);border-radius:14px;text-align:center}.error-card h1{font:700 28px Manrope,sans-serif}.error-card p{color:var(--muted)}@media(max-width:600px){.result-wrap{padding:55px 18px}.result-card{padding:38px 22px}.result-card h1{font-size:29px}}
  </style>
</head>
<body>
  <header class="site-header">
    <a class="brand" href="about.html"><span class="brand-mark">H</span> Hibernate Learning Lab</a>
    <a class="header-link" href="about.html">Back to the guide</a>
  </header>
  <main class="result-wrap">
<% if (validResult) { %>
    <section class="result-card" aria-live="polite">
      <p class="eyebrow">KNOWLEDGE CHECK COMPLETE</p>
      <h1>Well done, <span><%= escapeHtml(userName) %></span>!</h1>
      <div class="score-ring"><div class="score-inner"><span class="score-value"><%= score %>%</span><span class="score-unit">OUT OF 100</span></div></div>
      <p class="result-copy">Your score reflects the percentage of summary words that matched the Hibernate guide.</p>
      <p class="match-count"><%= matched %> of <%= total %> summary words matched the guide.</p>
      <div class="result-actions"><a class="button button-primary" href="test.html">Try again <span aria-hidden="true">→</span></a><a class="button button-secondary" href="about.html">Review the guide</a></div>
    </section>
<% } else { %>
    <section class="error-card">
      <p class="eyebrow">RESULT NOT FOUND</p>
      <h1>Submit a summary to see your score.</h1>
      <p>Complete the knowledge check first, and your result will appear here.</p>
      <a class="button button-primary" href="test.html">Go to the knowledge check <span aria-hidden="true">→</span></a>
    </section>
<% } %>
  </main>
  <footer class="site-footer"><span>Hibernate Learning Lab</span><span>Your learning, your next step</span></footer>
</body>
</html>
