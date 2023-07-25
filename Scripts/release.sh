VERSION="$1"
PREFIXED_VERSION="v$1"
NOTES="$2"

# Update version number
# Update CocoaPods podspec file
sed -i '' 's/\(^    s.version[^=]*= \).*/\1"'"$VERSION"'"/' mParticle-Google-Analytics-Firebase-GA4.podspec

# Make the release commit in git
#

git add mParticle-Google-Analytics-Firebase-GA4.podspec
git add mParticle_Google_Analytics_Firebase_GA4.json
git add CHANGELOG.md
git commit -m "chore(release): $VERSION [skip ci]

$NOTES"
