# Porkbun DNS Setup for storaapp.com

## 🎯 What You Need to Do

Add DNS records to make your website work at https://storaapp.com

---

## 📋 Step-by-Step Instructions

### Step 1: Log in to Porkbun

1. Go to https://porkbun.com/
2. Click "Login" (top right)
3. Enter your credentials

### Step 2: Go to DNS Settings

1. After login, find your domain **storaapp.com** in your domain list
2. Click on **storaapp.com**
3. Look for a tab or button that says **"DNS"** or **"DNS Records"**
4. Click it

### Step 3: Add DNS Records

You need to add **5 records total**. Here's what each one looks like:

---

#### ✅ Record 1: Website (apex domain)

```
Type: CNAME
Host: @
Answer: d1t6nfcjotkyin.cloudfront.net
TTL: 600
```

**What this does:** Makes https://storaapp.com point to your website

---

#### ✅ Record 2: Website (www subdomain)

```
Type: CNAME
Host: www
Answer: d1t6nfcjotkyin.cloudfront.net
TTL: 600
```

**What this does:** Makes https://www.storaapp.com work too

---

#### ✅ Record 3: Email DKIM #1

```
Type: CNAME
Host: htcxr4gmvwifvrbe5cox5uoa57f4sgph._domainkey
Answer: htcxr4gmvwifvrbe5cox5uoa57f4sgph.dkim.amazonses.com
TTL: 600
```

**What this does:** Helps your contact form emails not go to spam

---

#### ✅ Record 4: Email DKIM #2

```
Type: CNAME
Host: xtphh4goggpd2qsqa2aaaseifshgzpoo._domainkey
Answer: xtphh4goggpd2qsqa2aaaseifshgzpoo.dkim.amazonses.com
TTL: 600
```

**What this does:** Helps your contact form emails not go to spam

---

#### ✅ Record 5: Email DKIM #3

```
Type: CNAME
Host: dhmocqssrfq64mhmyc5nftlcaq55rpjs._domainkey
Answer: dhmocqssrfq64mhmyc5nftlcaq55rpjs.dkim.amazonses.com
TTL: 600
```

**What this does:** Helps your contact form emails not go to spam

---

## 🖱️ How to Add Each Record in Porkbun

For each of the 5 records above:

1. Click **"Add"** or **"Add Record"** button
2. Select **"CNAME"** from the Type dropdown
3. In the **"Host"** field, enter the Host value (e.g., `@` or `www`)
4. In the **"Answer"** field, enter the Answer value (e.g., `d1t6nfcjotkyin.cloudfront.net`)
5. Set **TTL** to **600** (or leave default)
6. Click **"Save"** or **"Add"**
7. Repeat for the next record

---

## 📸 Visual Guide

Here's what each field means:

```
┌─────────────────────────────────────┐
│ Add DNS Record                      │
├─────────────────────────────────────┤
│ Type: [CNAME ▼]                     │  ← Select "CNAME"
│                                     │
│ Host: [________________]            │  ← Put the "Host" here
│                                     │
│ Answer: [__________________]        │  ← Put the "Answer" here
│                                     │
│ TTL: [600]                          │  ← Put 600 (or leave default)
│                                     │
│ [Cancel]  [Save Record]             │  ← Click Save
└─────────────────────────────────────┘
```

---

## ⏱️ How Long Does It Take?

- DNS changes take **5 minutes to 48 hours** to propagate
- Usually works within **15-30 minutes**
- You can test using the CloudFront URL immediately: https://d1t6nfcjotkyin.cloudfront.net

---

## ✅ How to Verify It's Working

### Check DNS Propagation:

**Option 1: Use online tool**
- Go to https://dnschecker.org/
- Enter: `storaapp.com`
- Select: `CNAME`
- Click "Search"
- Should show: `d1t6nfcjotkyin.cloudfront.net`

**Option 2: Use terminal**
```bash
dig storaapp.com CNAME
```

Should see `d1t6nfcjotkyin.cloudfront.net` in the response.

### Test the Website:

Once DNS is working, visit:
- https://storaapp.com
- https://www.storaapp.com

Both should show your landing page! 🎉

---

## 🐛 Troubleshooting

### "I don't see a DNS section in Porkbun"
- Try looking for: "Manage Domain" → "DNS" or "Nameservers"
- Or contact Porkbun support, they're usually very helpful

### "It says I can't add a CNAME for @"
- Some DNS providers don't allow CNAME for apex (@)
- Try using ALIAS instead of CNAME (Porkbun should support this)
- Or try: Host = leave blank, Type = CNAME

### "The website still doesn't load after 24 hours"
- Check that all DNS records are saved correctly
- Make sure there are no typos in the CloudFront domain
- Try clearing your browser cache or use incognito mode
- Run: `dig storaapp.com` to see what DNS is returning

### "Contact form doesn't work"
- First verify the email: Check inbox for info@storaapp.com
- Click the verification link from AWS
- The form won't work until email is verified

---

## 📞 Need Help?

If you get stuck:
1. Take a screenshot of the Porkbun DNS page
2. Take a screenshot of any error messages
3. Run these commands and save the output:
   ```bash
   dig storaapp.com
   dig www.storaapp.com CNAME
   ```

---

## 📝 Quick Checklist

- [ ] All 5 DNS records added to Porkbun
- [ ] Records saved successfully  
- [ ] Waited 15-30 minutes for DNS propagation
- [ ] Clicked verification link in info@storaapp.com inbox
- [ ] Tested website at https://storaapp.com
- [ ] Tested contact form

---

**Last Updated:** January 12, 2026  
**Your CloudFront Domain:** d1t6nfcjotkyin.cloudfront.net  
**Your API Endpoint:** https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact
