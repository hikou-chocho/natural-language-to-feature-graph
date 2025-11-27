param(
    [string]$NaturalLanguageFile = "nl_ja.md",
    [string]$FeatureGraphJsonFile = "feature_graph.json",
    [string]$OutputJsonlFile = "nl_fg_messages.jsonl"
)

Write-Host "NaturalLanguageFile  = $NaturalLanguageFile"
Write-Host "FeatureGraphJsonFile = $FeatureGraphJsonFile"
Write-Host "OutputJsonlFile      = $OutputJsonlFile"

# --- Check existence ---
if (-not (Test-Path $NaturalLanguageFile)) {
    Write-Error "Natural language file not found: $NaturalLanguageFile"
    exit 1
}
if (-not (Test-Path $FeatureGraphJsonFile)) {
    Write-Error "FeatureGraph JSON file not found: $FeatureGraphJsonFile"
    exit 1
}

# --- Load natural language text ---
$nl = Get-Content $NaturalLanguageFile -Raw -Encoding UTF8

# --- Load FeatureGraph JSON ---
$fg_raw = Get-Content $FeatureGraphJsonFile -Raw

# --- Escape JSON for insertion ---
$fg_escaped = $fg_raw.Replace("\", "\\").Replace('"', '\"')

# --- Create JSONL content ---
$jsonl = @"
{"messages": [
  {"role": "system", "content": "You are a CAD feature graph generator. Output ONLY JSON."},
  {"role": "user",   "content": "$nl"},
  {"role": "assistant", "content": "$fg_escaped"}
]}
"@

# --- Write output ---
Set-Content -Path $OutputJsonlFile -Value $jsonl -Encoding UTF8

Write-Host "Generated: $OutputJsonlFile"
