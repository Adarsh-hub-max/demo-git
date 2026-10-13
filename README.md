# Hibernate Learning Lab

A Hibernate reading guide and summary quiz. `verify.jsp` validates the submitted name, Gmail address, and summary on the server. Successful submissions are redirected to `result.jsp`; invalid credentials return to the form with an error message. The verifier does not render a page in the browser.

## Run on Windows

Requirements: JDK 11 or newer (JDK 17 is recommended) and internet access for the first run. Maven is not required for the local run script.

From this project folder, run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-local.ps1
```

The script downloads Apache Tomcat 10.1.61 into the ignored `.runtime` folder, deploys the web application, and starts Tomcat on the first available port from 8081 through 8090. Open the URL printed by the script, usually:

`http://localhost:8081/hibernate-learning-lab/about.html`

Then use **Take the knowledge check**. A valid name must be exactly 10 characters and start with an uppercase letter, and the email must end in `@gmail.com`.

Stop the local server with:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop-local.ps1
```

The first run needs permission to reach `dlcdn.apache.org`. This is a local development setup; it does not install a Windows service.
