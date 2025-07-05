import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';

@Controller()
export class AccueilController {
  @Get(['/', '/api'])
  getAccueil(@Res() res: Response) {
    res.send(`
      <!DOCTYPE html>
      <html lang="fr">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Medibio SAV v2.1</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
          :root {
            --primary: #0066cc;
            --secondary: #00aaff;
            --dark: #1a2b50;
            --light: #f8f9ff;
          }
          
          body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--light) 0%, #e0e9ff 100%);
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            color: var(--dark);
          }
          
          .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.12);
            padding: 50px;
            max-width: 700px;
            width: 90%;
            margin: 2rem;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeIn 0.8s ease-out;
          }
          
          .logo-container {
            margin-bottom: 30px;
          }
          
          .logo {
            height: 80px;
            margin-bottom: 15px;
            filter: drop-shadow(0 5px 15px rgba(0, 102, 204, 0.2));
          }
          
          h1 {
            color: var(--primary);
            margin: 0 0 20px;
            font-size: 2.2rem;
            font-weight: 700;
          }
          
          p {
            color: #4a5568;
            font-size: 1.15rem;
            line-height: 1.8;
            margin-bottom: 30px;
            white-space: pre-line;
          }
          
          .features {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 30px 0;
            flex-wrap: wrap;
          }
          
          .feature {
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            flex: 1;
            min-width: 150px;
            border-left: 3px solid var(--secondary);
            cursor: pointer;
            transition: all 0.3s ease;
          }
          
          .feature:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
          }
          
.notification {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%) translateY(100px);
  background: var(--primary);
  color: white;
  padding: 15px 30px;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  opacity: 0;
  transition: all 0.4s ease;
  white-space: nowrap;
}

.notification.show {
  transform: translateX(-50%) translateY(0);
  opacity: 1;
}

          
          @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
          }
          
          @media (max-width: 768px) {
            .container {
              padding: 30px 20px;
            }
            
            h1 {
              font-size: 1.8rem;
            }
            
            .features {
              flex-direction: column;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="logo-container">
            <img src="https://www.macsievents.com/ckfinder/userfiles/images/2023/JNBC%202023/JNBC%201/MEDIBIO%20logo-01.jpg" 
                 alt="Medibio Logo" 
                 class="logo">
          </div>
          
          <h1>Medibio SAV V2<br></h1>

          
          
          <p>
            Plateforme de gestion des interventions
            parcs et articles Medibio
          </p>
          
          <div class="features">
            <div class="feature" onclick="showNotification('interventions')">Interventions</div>
            <div class="feature" onclick="showNotification('parcs')">Parcs</div>
            <div class="feature" onclick="showNotification('articles')">Articles</div>
          </div>
           <div class="endpoint-container">
            <span class="endpoint-label">URL de Base :</span>
            <div class="endpoint">http://172.16.20.7:4444/api/medibio-sav/v2</div>
          </div>
        </div>
          <div id="notification" class="notification"></div>
          
          <script>
            function showNotification(service) {
              const messages = {
                interventions: 'Service interventions est en cours de développement',
                parcs: 'Service parcs est en cours de développement',
                articles: 'Service articles est en cours de développement'
              };
              
              const notification = document.getElementById('notification');
              notification.textContent = messages[service];
              notification.classList.add('show');
              
              setTimeout(() => {
                notification.classList.remove('show');
              }, 4000);
            }
          </script>
        </div>
      </body>
      </html>
    `);
  }
}