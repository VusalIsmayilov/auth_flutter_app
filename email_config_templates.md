# 📧 Email Configuration Templates

## Current Configuration Status
Your backend has placeholder values that need to be updated with real email service credentials.

---

## 🚀 Quick Setup: SendGrid (Recommended)

### Step 1: Get SendGrid API Key
1. Go to [SendGrid.com](https://sendgrid.com/) and create free account
2. Go to Settings → API Keys → Create API Key
3. Choose "Restricted Access" with "Mail Send: Full Access"
4. Copy the API key (starts with "SG.")

### Step 2: Update Configuration Files

#### File: `/Users/vusalismayilov/Documents/asp.net_services/AuthService/appsettings.json`
Replace the Email section:
```json
{
  "Email": {
    "Provider": "SendGrid",
    "SendGridApiKey": "SG.your-actual-sendgrid-api-key-here",
    "FromEmail": "noreply@yourdomain.com",
    "FromName": "AuthService",
    "BaseUrl": "http://localhost:80"
  }
}
```

#### File: `/Users/vusalismayilov/Documents/asp.net_services/AuthService/appsettings.Development.json`
Replace the Email section:
```json
{
  "Email": {
    "Provider": "SendGrid",
    "SendGridApiKey": "SG.your-actual-sendgrid-api-key-here", 
    "FromEmail": "noreply@yourdomain.com",
    "FromName": "AuthService Development",
    "BaseUrl": "http://localhost:80"
  }
}
```

### Step 3: Verify Sender Email
1. In SendGrid dashboard: Settings → Sender Authentication
2. Click "Verify a Single Sender"
3. Use the same email as "FromEmail" above
4. Check your email and verify

---

## 🔧 Alternative: Gmail SMTP

If you prefer Gmail SMTP:

### Step 1: Setup Gmail
1. Enable 2-Factor Authentication on your Google account
2. Go to Security → App passwords
3. Generate app password for "Mail"

### Step 2: Update Configuration
```json
{
  "Email": {
    "Provider": "SMTP",
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUsername": "your-email@gmail.com",
    "SmtpPassword": "your-16-character-app-password",
    "FromEmail": "your-email@gmail.com", 
    "FromName": "AuthService",
    "EnableSsl": true,
    "BaseUrl": "http://localhost:80"
  }
}
```

---

## 🔐 Security Best Practice: Environment Variables

### Create `.env` file in AuthService directory:
```bash
# Email Configuration
SENDGRID_API_KEY=SG.your-actual-api-key-here
EMAIL_FROM_ADDRESS=noreply@yourdomain.com
EMAIL_FROM_NAME=AuthService

# Or for Gmail SMTP
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Update appsettings to use environment variables:
```json
{
  "Email": {
    "Provider": "SendGrid",
    "SendGridApiKey": "${SENDGRID_API_KEY}",
    "FromEmail": "${EMAIL_FROM_ADDRESS}",
    "FromName": "${EMAIL_FROM_NAME}",
    "BaseUrl": "http://localhost:80"
  }
}
```

---

## ✅ Testing Your Configuration

### Step 1: Restart Backend
```bash
cd /Users/vusalismayilov/Documents/asp.net_services/AuthService
dotnet run
```

### Step 2: Test Registration
1. Use the Flutter app to register a new user
2. Check logs for email sending confirmation
3. Check your email inbox

### Step 3: Monitor SendGrid Activity
1. Go to SendGrid Dashboard → Activity
2. View email delivery status
3. Check for any errors or bounces

---

## 📊 Configuration Verification

Use this checklist to verify your setup:

- [ ] SendGrid account created
- [ ] API key generated (starts with "SG.")
- [ ] Sender email verified in SendGrid
- [ ] appsettings.json updated with real values
- [ ] appsettings.Development.json updated
- [ ] Backend restarted
- [ ] Test email sent successfully
- [ ] Email received in inbox

---

## 🚨 Common Issues

### Issue: "Sender not verified"
**Solution**: Complete sender verification in SendGrid dashboard

### Issue: API key errors
**Solution**: Ensure API key starts with "SG." and has Mail Send permissions

### Issue: Emails go to spam
**Solution**: Complete domain authentication in SendGrid

### Issue: Rate limiting
**Solution**: SendGrid free tier: 100 emails/day limit

---

**Once you complete this setup, your email verification system will be fully functional!**

Which option would you like to proceed with? SendGrid or Gmail SMTP?