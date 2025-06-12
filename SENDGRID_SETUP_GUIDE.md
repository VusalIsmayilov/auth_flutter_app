# 📧 SendGrid Setup Guide for Email Verification

## Step-by-Step SendGrid Configuration

### 1. Create SendGrid Account
1. Visit [SendGrid.com](https://sendgrid.com/)
2. Click "Start for Free"
3. Fill out registration form
4. Verify your email address
5. Complete onboarding process

### 2. Create API Key
1. **Login to SendGrid Dashboard**
2. **Go to Settings** → **API Keys**
3. **Click "Create API Key"**
4. **Choose "Restricted Access"**
5. **Set permissions**:
   - Mail Send: **FULL ACCESS**
   - Template Engine: **READ ACCESS** (optional)
6. **Name your key**: `AuthService Email Verification`
7. **Click "Create & View"**
8. **Copy the API key** (you won't see it again!)

### 3. Verify Sender Identity
1. **Go to Settings** → **Sender Authentication**
2. **Choose one of these options**:

#### Option A: Single Sender Verification (Easiest)
1. Click "Verify a Single Sender"
2. Enter email details:
   - **From Email**: `noreply@yourdomain.com` (or your email)
   - **From Name**: `AuthService`
   - **Reply To**: Your email
   - **Company**: Your company name
   - **Address**: Your address
3. Click "Create"
4. Check your email and click verification link

#### Option B: Domain Authentication (Production)
1. Click "Authenticate Your Domain"
2. Enter your domain
3. Add DNS records to your domain
4. Verify domain ownership

### 4. Update Backend Configuration

Replace the configuration in your ASP.NET Core backend:

#### File: `appsettings.json`
```json
{
  "Email": {
    "Provider": "SendGrid",
    "SendGridApiKey": "SG.your-actual-api-key-here",
    "FromEmail": "noreply@yourdomain.com",
    "FromName": "AuthService",
    "BaseUrl": "http://localhost:80"
  }
}
```

#### File: `appsettings.Development.json`
```json
{
  "Email": {
    "Provider": "SendGrid",
    "SendGridApiKey": "SG.your-actual-api-key-here",
    "FromEmail": "noreply@yourdomain.com",
    "FromName": "AuthService Development",
    "BaseUrl": "http://localhost:80"
  }
}
```

### 5. Environment Variables (Optional but Recommended)
Create or update `.env` file:
```bash
SENDGRID_API_KEY=SG.your-actual-api-key-here
SMTP_FROM_EMAIL=noreply@yourdomain.com
SMTP_FROM_NAME=AuthService
```

### 6. Test Configuration
1. Restart your ASP.NET Core backend
2. Register a new user in the Flutter app
3. Check SendGrid Activity feed for email delivery
4. Check your email inbox

## Important Notes

### Free Tier Limits
- **100 emails/day** forever free
- **2,000 contacts**
- **Single sender verification**

### Production Considerations
1. **Domain Authentication**: Verify your domain for better deliverability
2. **Dedicated IP**: Consider for high volume (paid plans)
3. **Monitoring**: Use SendGrid analytics dashboard
4. **Templates**: Create reusable email templates

### Troubleshooting

#### Common Issues:
1. **"Sender not verified"**: Complete sender verification process
2. **API key invalid**: Check key format starts with "SG."
3. **Rate limiting**: Stay within daily limits
4. **SPAM folder**: Complete domain authentication

#### Check Email Activity:
1. Go to **Activity** in SendGrid dashboard
2. View delivery status of sent emails
3. Check for bounces or blocks

### Security Best Practices
1. **Never commit API keys** to version control
2. **Use environment variables** for secrets
3. **Restrict API key permissions** to minimum needed
4. **Rotate keys regularly**

## Alternative: Gmail SMTP Setup

If you prefer Gmail SMTP instead of SendGrid:

### 1. Enable 2-Factor Authentication
1. Go to Google Account settings
2. Enable 2-factor authentication

### 2. Generate App Password
1. Go to **Security** → **App passwords**
2. Select **Mail** and **Other (custom name)**
3. Enter "AuthService"
4. Copy the generated 16-character password

### 3. Update Configuration
```json
{
  "Email": {
    "Provider": "SMTP",
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUsername": "your-email@gmail.com",
    "SmtpPassword": "your-16-char-app-password",
    "FromEmail": "your-email@gmail.com",
    "FromName": "AuthService",
    "EnableSsl": true,
    "BaseUrl": "http://localhost:80"
  }
}
```

## Verification Checklist

- [ ] SendGrid account created
- [ ] API key generated and copied
- [ ] Sender email verified
- [ ] Backend configuration updated
- [ ] Backend restarted
- [ ] Test email sent successfully
- [ ] Email received in inbox
- [ ] Email verification flow working

Once completed, your email verification system will be fully functional!