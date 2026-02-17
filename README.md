# 🧪 Dispatch QA Reports

Beautiful, accessible QA reports for the Dispatch app suite.

**Live Dashboard:** [dispatch-reports.vercel.app](https://dispatch-reports.vercel.app)

## What's Here

- **Dashboard** (`index.html`) — Grid of all QA reports with pass/fail summaries
- **Reports** (`reports/`) — Individual HTML test reports with screenshots, accessibility data, and bug findings
- **Templates** (`templates/report.html`) — Copy this to create a new report
- **Assets** (`assets/`) — Screenshots organized by date

## Creating a New Report

### Option 1: Use the generator script

```bash
./scripts/generate-report.sh 2026-02-17 /path/to/screenshots findings.md
```

### Option 2: Manual

1. Copy `templates/report.html` to `reports/YYYY-MM-DD-test-name.html`
2. Replace all `{{PLACEHOLDER}}` values
3. Copy screenshots to `assets/YYYY-MM-DD/`
4. Add a card to `index.html`
5. Commit and push — Vercel auto-deploys

## Template Placeholders

| Placeholder | Example |
|---|---|
| `{{APP_NAME}}` | DispatchApp |
| `{{TEST_TYPE}}` | Simulator Test |
| `{{DATE}}` | 2026-02-16 |
| `{{ISO_DATE}}` | 2026-02-16T19:30:00-05:00 |
| `{{DISPLAY_DATE}}` | Feb 16, 2026 |
| `{{DEVICE}}` | iPhone 16 Pro Simulator (iOS 18.2) |
| `{{BRANCH}}` | main |
| `{{COMMIT}}` | abc1234 |
| `{{TESTER}}` | Mentat (Automated) |
| `{{STATUS}}` | Pass / Fail / In Progress |
| `{{TOTAL}}` | 10 |
| `{{PASSED}}` | 8 |
| `{{FAILED}}` | 1 |
| `{{SKIPPED}}` | 1 |
| `{{PENDING}}` | 0 |

## Tech Stack

- Pure HTML, CSS, vanilla JavaScript
- No frameworks, no build tools, no npm
- Static deployment on Vercel
- Dark mode design inspired by Linear/GitHub

## Design

- **Colors:** GitHub dark theme palette
- **Typography:** System font stack
- **Features:** Responsive, print-friendly, lightbox screenshots, collapsible sections
- **Accessibility:** Semantic HTML, ARIA labels, keyboard navigation

---

Built by [ArchieOS](https://github.com/ArchieOS-org)
