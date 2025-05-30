#!/bin/bash
# Build script for public Claude Code container

echo "🔨 Building public Claude Code container..."
echo ""

# Build the image
docker build -t arturrenzenbrink/dev:latest .

echo ""
echo "✅ Build complete!"
echo ""
echo "To run locally:"
echo "  docker run -it arturrenzenbrink/dev:latest"
echo ""
echo "To run with docker-compose:"
echo "  docker-compose up -d"
echo "  docker-compose exec claude-dev /bin/bash"
echo ""
echo "To push to Docker Hub:"
echo "  docker push arturrenzenbrink/dev:latest"