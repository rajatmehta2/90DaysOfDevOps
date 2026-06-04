package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Day 35 – Multi-Stage Builds & Docker Hub</title>
    <style>
        body {
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
            background: linear-gradient(135deg, #0e0a1c 0%, #150f2b 50%, #080512 100%);
            color: #E2E8F0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            overflow: hidden;
        }
        .container {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 48px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
            text-align: center;
            max-width: 540px;
            width: 90%;
            animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        h1 {
            font-size: 2.2rem;
            margin-bottom: 16px;
            background: linear-gradient(to right, #00f2fe, #4facfe);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 700;
        }
        p {
            font-size: 1.05rem;
            line-height: 1.6;
            color: #94A3B8;
            margin-bottom: 32px;
        }
        .badge {
            background: rgba(0, 242, 254, 0.1);
            color: #00f2fe;
            border: 1px solid rgba(0, 242, 254, 0.2);
            padding: 8px 16px;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 24px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .metrics {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-top: 32px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            padding-top: 24px;
        }
        .metric-card {
            background: rgba(255, 255, 255, 0.01);
            border: 1px solid rgba(255, 255, 255, 0.04);
            padding: 16px;
            border-radius: 12px;
        }
        .metric-value {
            font-size: 1.6rem;
            font-weight: 700;
            color: #00ff87;
            margin-bottom: 4px;
        }
        .metric-label {
            font-size: 0.75rem;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="badge">90 Days of DevOps</div>
        <h1>🐳 Day 35: Optimized Go Container 🚀</h1>
        <p>This lightweight Go web server is running inside an ultra-minimized, hardened multi-stage Docker container! It was built in a full Go SDK image, but runs inside a tiny Alpine footprint for top-tier security and speed.</p>
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-value" style="color: #ff4b2b;">839 MB</div>
                <div class="metric-label">Single-Stage Image</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">12.4 MB</div>
                <div class="metric-label">Multi-Stage Image</div>
            </div>
        </div>
    </div>
</body>
</html>
		`)
	})

	fmt.Println("🚀 Web Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Printf("Fatal error: %s\n", err)
	}
}
