# Static Generation Script for TrueWebX Extreme SEO
# Config - Use environment variables for security in GitHub Actions
$supabaseUrl = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { 'https://vrpyomevjlsacourdmki.supabase.co' }
$supabaseKey = if ($env:SUPABASE_SERVICE_ROLE_KEY) { $env:SUPABASE_SERVICE_ROLE_KEY } else { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZycHlvbWV2amxzYWNvdXJkbWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjE3MDg4NSwiZXhwIjoyMDgxNzQ2ODg1fQ.cPaMJJF6IqPV-KeT8_qux8dRXcyD7yFFds_ifRs3-yI' }

if (-not $supabaseUrl -or -not $supabaseKey) {
    Write-Error "Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables."
    exit 1
}

$headers = @{
    "apikey" = $supabaseKey
    "Authorization" = "Bearer $supabaseKey"
}

Write-Host "Fetching data from Supabase..."
try {
    $response = Invoke-RestMethod -Uri "$supabaseUrl/rest/v1/services?select=*" -Headers $headers -Method Get
    $businesses = $response
} catch {
    Write-Error "Failed to fetch data from Supabase: $_"
    exit 1
}

$templatePath = "service.html" # Use this as the base structure
$sitemapPath = "sitemap.xml"
$today = Get-Date -Format "yyyy-MM-dd"

# Initialize Sitemap XML
$sitemapXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">

  <!-- Home -->
  <url>
    <loc>https://truewebx.site/</loc>
    <lastmod>$today</lastmod>
    <changefreq>always</changefreq>
    <priority>1.0</priority>
  </url>

  <!-- Dashboard -->
  <url>
    <loc>https://truewebx.site/dashboard.html</loc>
    <lastmod>$today</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.8</priority>
  </url>

  <!-- Messaging -->
  <url>
    <loc>https://truewebx.site/message.html</loc>
    <lastmod>$today</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.7</priority>
  </url>
"@

foreach ($b in $businesses) {
    if (-not $b.slug) { continue }
    
    $profileDir = "profile/$($b.slug)"
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force
    }

    # preparing SEO content
    $cityName = ($b.city -split ",")[0].Trim()
    $stateInfo = ($b.city -split ",")[1].Trim()
    $zipCode = ($stateInfo -split " ")[-1]

    # Add to Sitemap XML with Full Image Indexing
    $sitemapXml += @"

  <url>
    <loc>https://truewebx.site/profile/$($b.slug)/</loc>
    <lastmod>$today</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
    <image:image>
      <image:loc>$($b.profile)</image:loc>
      <image:title>$($b.name) - Official Profile</image:title>
    </image:image>
"@
    # Add gallery images to sitemap for extreme image-search dominance
    if ($b.photos) {
        foreach ($photo in $b.photos) {
            $sitemapXml += @"
    <image:image>
      <image:loc>$photo</image:loc>
      <image:title>$($b.name) - $niche Service Gallery</image:title>
    </image:image>
"@
        }
    }
    $sitemapXml += @"
  </url>
"@

    # Extreme Niche Extraction (identifying what they DO)
    $niche = "Professional Services"
    $desc = $b.description.ToLower()
    if ($desc -match "airbnb|short-term|turnover") { $niche = "Airbnb & Vacation Rental Cleaning" }
    elseif ($desc -match "commercial|office|janitorial") { $niche = "Commercial Cleaning & Janitorial" }
    elseif ($desc -match "cleaning|maid|housekeeping") { $niche = "Residential Cleaning Services" }
    elseif ($desc -match "lawn|grass|landscaping|mowing") { $niche = "Lawn Care & Professional Landscaping" }
    elseif ($desc -match "barber|hair|salon|fade") { $niche = "Precision Barbering & Grooming" }
    elseif ($desc -match "roofing|construction|renovation|remodel") { $niche = "Home Remodeling & Construction" }
    elseif ($desc -match "moving|relocation|transport") { $niche = "Professional Moving & Logistics" }
    elseif ($desc -match "pest|bug|exterminator") { $niche = "Expert Pest Control" }
    elseif ($desc -match "plumbing|pipe|leak") { $niche = "Licensed Plumbing Services" }

    # Advanced Dynamic SEO Metadata
    $pageTitle = "#1 $($b.name) - Best $niche in $cityName, $stateInfo"
    $pageDesc = "Looking for the top-rated $niche in $($cityName)? $($b.name) specializes in high-quality professional solutions. Verified expert in $zipCode. Call $($b.phone) for the best local service near you."
    $cleanPhone = $b.phone -replace '[^0-9]', ''
    $seoKeywords = "$niche in $cityName, best $($b.name) $cityName, professional $niche $zipCode, verified local experts"
    
    # Social Links HTML
    $socialHtml = ""
    if ($b.social_links) {
        foreach ($link in $b.social_links) {
            $type = $link.type.ToLower()
            $icon = switch ($type) {
                "instagram" { "instagram" }
                "tiktok" { "tiktok" }
                "facebook" { "facebook-f" }
                "twitter" { "twitter" }
                "linkedin" { "linkedin-in" }
                "youtube" { "youtube" }
                default { "globe" }
            }
            $socialHtml += "<a href='$($link.url)' target='_blank' rel='noopener' class='social-btn $type' aria-label='$($link.type)'><i class='fab fa-$icon'></i></a>"
        }
    }

    # Gallery HTML (Interactive Slider)
    $galleryHtml = ""
    if ($b.photos -and $b.photos.Count -gt 0) {
        $galleryHtml = @"
    <h2 style="font-size: 2.8rem; margin: 70px 0 30px;">Gallery</h2>
    <div class="gallery-wrapper" id="galleryWrapper">
        <div class="gallery-slider" id="gallerySlider">
"@
        foreach ($photo in $b.photos) {
            $galleryHtml += "<img src='$photo' alt='Professional $niche provided by $($b.name) in $cityName, $stateInfo' loading='lazy' decoding='async'>"
        }
        $galleryHtml += @"
        </div>
        <button class="gallery-arrow prev" id="prevBtn" aria-label="Previous image"><i class="fas fa-chevron-left"></i></button>
        <button class="gallery-arrow next" id="nextBtn" aria-label="Next image"><i class="fas fa-chevron-right"></i></button>
    </div>
"@
    }

    # Related Profiles Logic
    $relatedProfilesHtml = ""
    $related = $businesses | Where-Object { $_.id -ne $b.id } | Sort-Object { $_.city -eq $b.city } -Descending | Select-Object -First 3
    if ($related) {
        $relatedProfilesHtml = @"
    <h2 style="font-size: 2.8rem; margin: 100px 0 40px; text-align: center; width: 100%;">Related Businesses in Your Area</h2>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-bottom: 60px; width: 100%;">
"@
        foreach ($r in $related) {
            $rCity = ($r.city -split ",")[0].Trim()
            $relatedProfilesHtml += @"
        <a href="https://truewebx.site/profile/$($r.slug)/" style="text-decoration: none; color: white;">
            <div style="background: rgba(255,255,255,0.08); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); transition: 0.3s;" onmouseover="this.style.background='rgba(255,255,255,0.15)'; this.style.transform='translateY(-5px)'" onmouseout="this.style.background='rgba(255,255,255,0.08)'; this.style.transform='none'">
                <img src="$($r.profile)" alt="$($r.name)" style="width: 100%; height: 180px; object-fit: cover; border-radius: 12px; margin-bottom: 15px;">
                <h3 style="font-size: 1.4rem; margin-bottom: 10px;">$($r.name)</h3>
                <p style="opacity: 0.8; font-size: 0.95rem;"><i class="fas fa-map-marker-alt" style="color: var(--coral); margin-right: 5px;"></i> $rCity</p>
            </div>
        </a>
"@
        }
        $relatedProfilesHtml += "</div>"
    }

    # Build the HTML content
    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$pageTitle</title>
  <meta name="description" content="$pageDesc">
  <meta name="keywords" content="$seoKeywords">
  <link rel="canonical" href="https://truewebx.site/profile/$($b.slug)/">
  <link rel="icon" type="image/png" href="$($b.profile)">
  <link rel="apple-touch-icon" href="$($b.profile)">
  <meta property="og:type" content="business.business">
  <meta property="og:title" content="$pageTitle">
  <meta property="og:description" content="$pageDesc">
  <meta property="og:image" content="$($b.profile)">
  <meta property="og:url" content="https://truewebx.site/profile/$($b.slug)/">
  <meta property="og:site_name" content="TrueWebX">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$pageTitle">
  <meta name="twitter:description" content="$pageDesc">
  <meta name="twitter:image" content="$($b.profile)">
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
  <style>
    :root { 
      --coral: #ff6b6b; 
      --turquoise: #0d9488; 
      --text: #ffffff; 
      --glass: rgba(255, 255, 255, 0.08); 
      --glass-border: rgba(255, 255, 255, 0.12);
      --bg: #030712;
      --accent: #f8fafc;
    }
    
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Outfit', sans-serif; }
    
    body { 
      background: var(--bg); 
      color: var(--text); 
      min-height: 100vh; 
      overflow-x: hidden;
      line-height: 1.5;
    }

    /* Modern Background Blobs */
    .bg-blobs { position: fixed; inset: 0; z-index: -1; overflow: hidden; filter: blur(100px); opacity: 0.6; pointer-events: none; }
    .blob { position: absolute; border-radius: 50%; animation: float 20s infinite alternate; }
    .blob-1 { width: 600px; height: 600px; background: var(--turquoise); top: -100px; left: -100px; opacity: 0.4; }
    .blob-2 { width: 500px; height: 500px; background: var(--coral); bottom: -100px; right: -100px; opacity: 0.3; }
    .blob-3 { width: 400px; height: 400px; background: #6366f1; top: 40%; left: 30%; opacity: 0.2; }
    @keyframes float { 0% { transform: translate(0, 0) scale(1); } 100% { transform: translate(100px, 50px) scale(1.1); } }

    /* Floating Dock Navigation */
    .nav-dock {
        position: fixed;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(15, 23, 42, 0.6);
        backdrop-filter: blur(25px) saturate(180%);
        -webkit-backdrop-filter: blur(25px) saturate(180%);
        border: 1px solid var(--glass-border);
        padding: 8px 12px;
        border-radius: 30px;
        display: flex;
        gap: 8px;
        z-index: 10000;
        box-shadow: 0 20px 40px rgba(0,0,0,0.5);
    }
    .nav-item {
        color: white;
        text-decoration: none;
        padding: 10px 18px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.9rem;
        transition: 0.3s cubic-bezier(0.23, 1, 0.32, 1);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .nav-item:hover { background: rgba(255,255,255,0.1); transform: translateY(-4px); }
    .nav-item.active { background: white; color: black; }

    /* Bento Grid Layout */
    .bento-container {
        max-width: 1400px;
        margin: 40px auto 140px;
        padding: 0 24px;
        display: grid;
        grid-template-columns: repeat(12, 1fr);
        grid-auto-rows: minmax(100px, auto);
        gap: 20px;
    }

    .bento-card {
        background: var(--glass);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid var(--glass-border);
        border-radius: 32px;
        padding: 32px;
        transition: 0.4s cubic-bezier(0.23, 1, 0.32, 1);
        position: relative;
        overflow: hidden;
    }
    .bento-card:hover { transform: translateY(-5px); border-color: rgba(255,255,255,0.3); box-shadow: 0 20px 40px rgba(0,0,0,0.3); }

    /* Card Specifics */
    .card-hero { grid-column: span 8; grid-row: span 3; display: flex; flex-direction: column; justify-content: flex-end; align-items: flex-start; text-align: left; }
    .card-profile { grid-column: span 4; grid-row: span 3; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; background: linear-gradient(135deg, rgba(255,255,255,0.05), transparent); }
    .card-gallery { grid-column: span 8; grid-row: span 4; padding: 0; }
    .card-expertise { grid-column: span 4; grid-row: span 4; display: flex; flex-direction: column; justify-content: flex-start; }
    .card-social { grid-column: span 4; grid-row: span 3; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .card-contact { grid-column: span 8; grid-row: span 3; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .card-related { grid-column: span 12; margin-top: 40px; }

    .expertise-list { list-style: none; margin-top: 10px; padding: 0; }
    .expertise-list li { margin-bottom: 15px; display: flex; align-items: flex-start; gap: 12px; font-weight: 600; font-size: 1.05rem; }
    .expertise-list li i { color: #4ade80; font-size: 1.2rem; margin-top: 4px; }

    /* Elements */
    .profile-img { 
        width: 180px; height: 180px; 
        object-fit: cover; 
        border-radius: 40px; 
        border: 4px solid var(--coral); 
        margin-bottom: 20px;
        box-shadow: 0 15px 30px rgba(0,0,0,0.5);
        transition: 0.5s;
    }
    .profile-img:hover { transform: rotate(5deg) scale(1.05); }

    h1 { font-size: 3.5rem; font-weight: 800; line-height: 1.1; margin-bottom: 20px; letter-spacing: -2px; }
    .badge { background: var(--coral); color: white; padding: 6px 16px; border-radius: 20px; font-size: 0.8rem; font-weight: 800; text-transform: uppercase; margin-bottom: 15px; display: inline-block; }
    
    .status-ping { display: inline-flex; align-items: center; gap: 8px; font-size: 0.9rem; font-weight: 600; opacity: 0.8; margin-top: 10px; }
    .status-ping span { width: 10px; height: 10px; background: #4ade80; border-radius: 50%; box-shadow: 0 0 10px #4ade80; animation: pulse 2s infinite; }
    @keyframes pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.5); opacity: 0.5; } 100% { transform: scale(1); opacity: 1; } }

    .description { font-size: 1.1rem; line-height: 1.7; opacity: 0.8; }
    
    .contact-item { 
        display: flex; align-items: center; gap: 15px; 
        padding: 20px; background: rgba(255,255,255,0.05); 
        border-radius: 24px; border: 1px solid transparent; 
        transition: 0.3s; text-decoration: none; color: white;
    }
    .contact-item:hover { background: rgba(255,255,255,0.1); border-color: var(--glass-border); transform: translateX(10px); }
    .contact-item i { font-size: 1.5rem; color: var(--coral); }
    
    .gallery-wrapper { position: relative; width: 100%; height: 100%; border-radius: 32px; overflow: hidden; }
    .gallery-slider { display: flex; height: 100%; transition: transform 0.6s cubic-bezier(0.23, 1, 0.32, 1); }
    .gallery-slider img { width: 100%; height: 100%; object-fit: cover; flex-shrink: 0; }
    .gallery-nav { position: absolute; bottom: 24px; left: 50%; transform: translateX(-50%); display: flex; gap: 10px; z-index: 10; }
    .gallery-dot { width: 12px; height: 12px; border-radius: 50%; background: rgba(255,255,255,0.3); border: none; cursor: pointer; transition: 0.3s; }
    .gallery-dot.active { background: white; transform: scale(1.3); }

    .action-btn { 
        width: 100%; background: var(--coral); color: white; 
        padding: 24px; border-radius: 24px; border: none; 
        font-size: 1.2rem; font-weight: 800; cursor: pointer; 
        transition: 0.4s; display: flex; align-items: center; 
        justify-content: center; gap: 12px; box-shadow: 0 10px 30px rgba(255, 107, 107, 0.3);
    }
    .action-btn:hover { background: #ff5252; transform: translateY(-5px); box-shadow: 0 20px 50px rgba(255, 107, 107, 0.4); }

    .gallery-arrow {
        position: absolute; top: 50%; transform: translateY(-50%);
        background: rgba(255,255,255,0.1); backdrop-filter: blur(10px);
        border: 1px solid var(--glass-border); color: white;
        width: 50px; height: 50px; border-radius: 50%;
        cursor: pointer; z-index: 100; transition: 0.3s;
        display: flex; align-items: center; justify-content: center;
    }
    .gallery-arrow:hover { background: white; color: black; }
    .gallery-arrow.prev { left: 20px; }
    .gallery-arrow.next { right: 20px; }

    .social-links-grid { display: flex; gap: 15px; flex-wrap: wrap; justify-content: center; }
    .social-btn { 
        width: 70px; height: 70px; border-radius: 24px; 
        background: rgba(255,255,255,0.05); border: 1px solid var(--glass-border); 
        color: white; display: grid; place-items: center; 
        font-size: 1.8rem; transition: 0.3s; text-decoration: none;
    }
    .social-btn:hover { background: white; color: black; transform: translateY(-5px) rotate(8deg); }
    .social-btn.facebook:hover { color: #1877F2; border-color: #1877F2; }
    .social-btn.instagram:hover { color: #E4405F; border-color: #E4405F; }
    .social-btn.twitter:hover { color: #1DA1F2; border-color: #1DA1F2; }
    .social-btn.linkedin:hover { color: #0A66C2; border-color: #0A66C2; }
    .social-btn.tiktok:hover { color: #fe2c55; border-color: #fe2c55; }
    .social-btn.youtube:hover { color: #FF0000; border-color: #FF0000; }

    .card-social { grid-column: span 4; grid-row: span 2; display: flex; flex-direction: column; align-items: center; justify-content: center; }

    /* Mobile Responsive */
    @media (max-width: 1024px) {
        .card-hero, .card-profile, .card-gallery, .card-contact { grid-column: span 12; }
        .bento-container { margin-top: 20px; }
        h1 { font-size: 2.5rem; }
    }

    /* Messaging UI Parity */
    #msgModal { background: rgba(0,0,0,0.8); backdrop-filter: blur(20px); }
    .chat-container { background: #0f172a; border-radius: 40px; border: 1px solid var(--glass-border); }
    .bubble { 
        padding: 14px 20px; 
        border-radius: 24px; 
        max-width: 85%; 
        position: relative; 
        font-size: 1rem; 
        line-height: 1.5; 
        animation: bubblePop 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); 
        cursor: pointer;
        transition: transform 0.2s;
    }
    .bubble.client { background: var(--coral); color: white; }
    .bubble.owner { background: rgba(255,255,255,0.05); }
    @keyframes bubblePop { from { transform: scale(0.8) translateY(20px); opacity: 0; } to { transform: scale(1) translateY(0); opacity: 1; } }
  </style>
  <script type="application/ld+json">
  [
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "TrueWebX", "item": "https://truewebx.site/" },
        { "@type": "ListItem", "position": 2, "name": "Profiles", "item": "https://truewebx.site/profile/" },
        { "@type": "ListItem", "position": 3, "name": "$($b.name)", "item": "https://truewebx.site/profile/$($b.slug)/" }
      ]
    },
    {
      "@context": "https://schema.org",
      "@type": "LocalBusiness",
      "name": "$($b.name)",
      "image": "$($b.profile)",
      "url": "https://truewebx.site/profile/$($b.slug)/",
      "telephone": "$($b.phone)",
      "email": "$($b.gmail)",
      "priceRange": "$$",
      "openingHours": "Mo-Su 08:00-18:00",
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "$cityName",
        "postalCode": "$zipCode",
        "addressCountry": "US"
      },
      "description": "$($b.description.Replace('"', '\"').Replace("`n", "\n").Replace("`r", ""))",
      "aggregateRating": {
        "@type": "AggregateRating",
        "ratingValue": "5",
        "reviewCount": "24"
      },
      "hasOfferCatalog": {
        "@type": "OfferCatalog",
        "name": "$niche",
        "itemListElement": [
          {
            "@type": "Offer",
            "itemOffered": {
              "@type": "Service",
              "name": "$niche"
            }
          }
        ]
      }
    }
  ]
  </script>
</head>
<body>
  <div class="bg-blobs">
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>
  </div>

  <nav class="nav-dock">
    <a href="https://truewebx.site/" class="nav-item"><i class="fas fa-home"></i> Home</a>
    <a href="https://truewebx.site/directory.html" class="nav-item active"><i class="fas fa-compass"></i> Discover</a>
    <a href="https://truewebx.site/dashboard.html" class="nav-item"><i class="fas fa-user-circle"></i> Account</a>
  </nav>

  <div class="bento-container">
    <div class="bento-card card-hero">
        <div class="badge">Verified Expert</div>
        <h1>$($b.name)</h1>
        <div class="description">$($b.description.Replace("`n", "<br>"))</div>
    </div>

    <div class="bento-card card-profile">
        <img src="$($b.profile)" alt="$($b.name) profile" class="profile-img">
        <div style="font-size:1.4rem; font-weight:800; margin-bottom:5px;">$cityName</div>
        <div style="opacity:0.6;"><i class="fas fa-map-marker-alt"></i> $($b.city)</div>
        <div class="status-ping"><span></span> Online Now</div>
    </div>

    <div class="bento-card card-gallery">
        $galleryHtml
    </div>

    <div class="bento-card card-expertise">
        <div style="font-size:1.6rem; font-weight:800; margin-bottom:20px; color:var(--coral);">Expertise & Focus</div>
        <ul class="expertise-list">
            <li><i class="fas fa-check-circle"></i> Pre-Vetted $niche</li>
            <li><i class="fas fa-shield-alt"></i> Fully Licensed & Insured Operative</li>
            <li><i class="fas fa-star"></i> High-End Equipment & Tech</li>
            <li><i class="fas fa-map-marked-alt"></i> Local $cityName Territory Expert</li>
            <li><i class="fas fa-calendar-check"></i> Standardized Professional Quality</li>
        </ul>
        <div style="margin-top:auto; padding-top:20px; border-top:1px solid var(--glass-border); font-size:0.9rem; opacity:0.6;">
            Specializing in precision solutions for both residential and commercial needs in $cityName.
        </div>
    </div>

    <div class="bento-card card-social">
        <div style="font-size:1.5rem; font-weight:800; margin-bottom:20px; text-align:center;">Social Network</div>
        <div class="social-links-grid">
            $socialHtml
        </div>
    </div>

    <div class="bento-card card-contact" style="flex-direction: row; flex-wrap: wrap;">
        <div style="grid-column: span 2; font-size:1.8rem; font-weight:800; margin-bottom:10px;">Immediate Contact</div>
        <a href="tel:$cleanPhone" class="contact-item" style="flex:1;">
            <i class="fas fa-phone"></i>
            <div>
                <div style="font-size:0.8rem; opacity:0.6;">Direct Line</div>
                <div style="font-weight:600;">$($b.phone)</div>
            </div>
        </a>
        <a href="mailto:$($b.gmail)" class="contact-item" style="flex:1;">
            <i class="fas fa-envelope"></i>
            <div>
                <div style="font-size:0.8rem; opacity:0.6;">Direct Reach</div>
                <div style="font-weight:600;">Mail Me</div>
            </div>
        </a>
        <button class="action-btn" onclick="openContactChat('$($b.id)')" style="grid-column: span 2;">
            <i class="fas fa-paper-plane"></i> Message Owner & Get a Free Quote
        </button>
    </div>

    <div class="card-related" style="grid-column: span 12;">
        $relatedProfilesHtml
    </div>

    <div class="bento-card" style="grid-column: span 12; text-align: center; background: transparent; border: none;">
        <p style="opacity:0.5;">Powered by <strong>TrueWebX</strong> &bull; The Next Generation of Business Discovery</p>
    </div>
  </div>

  <!-- Super Modern Messaging Modal -->
  <div id="msgModal" style="display:none; position:fixed; inset:0; z-index:99999; justify-content:center; align-items:center; background:rgba(0,0,0,0.4); backdrop-filter:blur(20px); opacity:0; transition:opacity 0.4s ease;">
      <div class="chat-container" style="width:95%; max-width:600px; height: 85vh; background:rgba(15, 23, 42, 0.8); backdrop-filter:blur(40px); border:1px solid var(--glass-border); border-radius:48px; display:flex; flex-direction:column; position:relative; overflow:hidden; transform:scale(0.9); transition:transform 0.4s cubic-bezier(0.23, 1, 0.32, 1); box-shadow:0 40px 100px rgba(0,0,0,0.8);">
          <div style="padding:40px; text-align:center; flex:1; display:flex; flex-direction:column;">
              <button onclick="window.closeModal()" style="position:absolute; top:30px; right:30px; background:white; border:none; width:44px; height:44px; border-radius:50%; color:black; font-size:24px; cursor:pointer; display:grid; place-items:center; transition:0.3s; z-index:100;">&times;</button>
              <h2 style="font-size:2rem; font-weight:800; margin-bottom:30px;">Live Messaging</h2>
              <div id="chatHistory" style="flex:1; overflow-y:auto; margin:20px 0; padding:20px; display:flex; flex-direction:column; gap:15px; mask-image:linear-gradient(to bottom, transparent, black 10%, black 90%, transparent);"></div>
              <form id="contactForm" onsubmit="event.preventDefault(); sendMessage('$($b.id)');" style="display:flex; gap:15px; padding:20px; background:rgba(255,255,255,0.05); border-radius:40px; border:1px solid var(--glass-border);">
                  <input type="text" id="custMsg" placeholder="Type your message..." style="flex:1; padding:15px 25px; border-radius:30px; border:none; background:transparent; color:white; font-size:1.1rem; outline:none;">
                  <button type="submit" style="width:54px; height:54px; border-radius:50%; background:white; color:black; border:none; display:grid; place-items:center; cursor:pointer; font-size:1.2rem; transition:0.3s;"><i class="fas fa-paper-plane"></i></button>
              </form>
          </div>
      </div>
  </div>

  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <script>
    const firebaseConfig = {
        apiKey: "AIzaSyBam-ZJXtbgHnhI7IeGLgKS-HeRdSBQNS0",
        authDomain: "limpieza-digital.firebaseapp.com",
        projectId: "limpieza-digital",
        storageBucket: "limpieza-digital.firebasestorage.app",
        messagingSenderId: "410437614466",
        appId: "1:410437614466:web:8abec9eb1189a2369bad9b"
    };
    firebase.initializeApp(firebaseConfig);
    const auth = firebase.auth();
    const supabaseClient = supabase.createClient('$supabaseUrl', '$supabaseKey');

    let chatTimer = null;
    window.closeModal = () => {
        const modal = document.getElementById('msgModal');
        const container = modal.querySelector('.chat-container');
        modal.style.opacity = '0';
        container.style.transform = 'scale(0.9)';
        setTimeout(() => {
            modal.style.display = 'none';
            if (chatTimer) clearInterval(chatTimer);
        }, 400);
    };
    window.openContactChat = (id) => {
        const modal = document.getElementById('msgModal');
        const container = modal.querySelector('.chat-container');
        modal.style.display = 'flex';
        setTimeout(() => {
            modal.style.opacity = '1';
            container.style.transform = 'scale(1)';
        }, 10);
        if (chatTimer) clearInterval(chatTimer);
        // ... previous load history logic ...
    };

    const slider = document.getElementById('gallerySlider');
    const nav = document.getElementById('galleryNav');
    const prev = document.getElementById('prevBtn');
    const next = document.getElementById('nextBtn');

    if (slider) {
        const count = slider.children.length;
        let currentIdx = 0;

        const updateGallery = (idx) => {
            slider.style.transform = "translateX(-" + (idx * 100) + "%)";
            if (nav) {
                const dots = nav.querySelectorAll('.gallery-dot');
                dots.forEach((d, i) => d.classList.toggle('active', i === idx));
            }
            currentIdx = idx;
        };

        if (nav && count > 1) {
            for(let i=0; i<count; i++) {
                const dot = document.createElement('button');
                dot.className = 'gallery-dot' + (i===0?' active':'');
                dot.onclick = () => updateGallery(i);
                nav.appendChild(dot);
            }
        }

        if (prev && next && count > 1) {
            prev.onclick = () => updateGallery((currentIdx - 1 + count) % count);
            next.onclick = () => updateGallery((currentIdx + 1) % count);
        } else if (prev && next) {
            prev.style.display = 'none';
            next.style.display = 'none';
        }
    }
  </script>
</body>
</html>
"@
    # Use .NET method to ensure consistent UTF-8 without BOM issues
    [System.IO.File]::WriteAllText("$profileDir/index.html", $htmlContent, [System.Text.Encoding]::UTF8)
    Write-Host "Generated static page (Bento Redesign) for: $($b.name)"
}

# Cleanup: Delete directories in 'profile/' that are no longer in Supabase
$allValidSlugs = $businesses.slug
$existingProfiles = Get-ChildItem -Path profile -Directory
foreach ($dir in $existingProfiles) {
    if ($allValidSlugs -notcontains $dir.Name) {
        Write-Host "Deleting stale profile: $($dir.Name)"
        Remove-Item -Path $dir.FullName -Recurse -Force
    }
}

# Finalize Sitemap XML
$sitemapXml += "`n</urlset>"
[System.IO.File]::WriteAllText($sitemapPath, $sitemapXml, [System.Text.Encoding]::UTF8)
Write-Host "Sitemap updated successfully with $($businesses.Count) records."
