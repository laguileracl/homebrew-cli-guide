#!/usr/bin/env node
/**
 * CLI Tools API Server
 * RESTful API for querying the Homebrew CLI Guide
 */

const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Cache para los datos
let toolsData = null;
let lastUpdate = null;

// Cargar datos del índice
async function loadToolsData() {
  try {
    const dataPath = path.join(__dirname, '../tools-index.json');
    const data = await fs.readFile(dataPath, 'utf8');
    toolsData = JSON.parse(data);
    lastUpdate = new Date();
    console.log(`📚 Loaded ${toolsData.tools.length} tools from index`);
  } catch (error) {
    console.error('❌ Error loading tools data:', error);
    throw error;
  }
}

// Middleware para validar que los datos estén cargados
const ensureDataLoaded = async (req, res, next) => {
  if (!toolsData) {
    try {
      await loadToolsData();
    } catch (error) {
      return res.status(500).json({ 
        error: 'Failed to load tools data',
        message: error.message 
      });
    }
  }
  next();
};

// === ROUTES ===

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    dataLoaded: !!toolsData,
    lastUpdate: lastUpdate?.toISOString()
  });
});

// API Info
app.get('/api', ensureDataLoaded, (req, res) => {
  res.json({
    name: 'Homebrew CLI Guide API',
    version: '1.0.0',
    description: 'RESTful API for querying CLI tools',
    endpoints: {
      'GET /api/tools': 'Get all tools with optional filtering',
      'GET /api/tools/:name': 'Get specific tool by name',
      'GET /api/categories': 'Get all categories',
      'GET /api/stats': 'Get statistics',
      'GET /api/search': 'Search tools by query',
      'GET /api/random': 'Get random tool recommendation'
    },
    metadata: toolsData.metadata
  });
});

// Get all tools with filtering
app.get('/api/tools', ensureDataLoaded, (req, res) => {
  const { 
    category, 
    difficulty, 
    tag, 
    limit = 100, 
    offset = 0,
    sort = 'name',
    order = 'asc'
  } = req.query;

  let filteredTools = [...toolsData.tools];

  // Apply filters
  if (category) {
    filteredTools = filteredTools.filter(tool => 
      tool.category === category
    );
  }

  if (difficulty) {
    filteredTools = filteredTools.filter(tool => 
      tool.difficulty === difficulty
    );
  }

  if (tag) {
    filteredTools = filteredTools.filter(tool => 
      tool.tags && tool.tags.includes(tag)
    );
  }

  // Sort
  filteredTools.sort((a, b) => {
    const aVal = a[sort] || '';
    const bVal = b[sort] || '';
    const comparison = aVal.localeCompare(bVal);
    return order === 'desc' ? -comparison : comparison;
  });

  // Pagination
  const startIdx = parseInt(offset);
  const endIdx = startIdx + parseInt(limit);
  const paginatedTools = filteredTools.slice(startIdx, endIdx);

  res.json({
    tools: paginatedTools,
    pagination: {
      total: filteredTools.length,
      limit: parseInt(limit),
      offset: parseInt(offset),
      hasMore: endIdx < filteredTools.length
    },
    filters: { category, difficulty, tag }
  });
});

// Get specific tool
app.get('/api/tools/:name', ensureDataLoaded, (req, res) => {
  const toolName = req.params.name.toLowerCase();
  const tool = toolsData.tools.find(t => 
    t.name.toLowerCase() === toolName
  );

  if (!tool) {
    return res.status(404).json({ 
      error: 'Tool not found',
      suggestion: 'Use /api/search?q=toolname to find similar tools'
    });
  }

  // Enrich with related tools
  const relatedTools = toolsData.tools
    .filter(t => 
      t.category === tool.category && 
      t.name !== tool.name
    )
    .slice(0, 3);

  res.json({
    ...tool,
    related: relatedTools
  });
});

// Search tools
app.get('/api/search', ensureDataLoaded, (req, res) => {
  const { q, limit = 20 } = req.query;

  if (!q) {
    return res.status(400).json({ 
      error: 'Query parameter "q" is required' 
    });
  }

  const query = q.toLowerCase();
  const results = toolsData.tools.filter(tool => {
    return (
      tool.name.toLowerCase().includes(query) ||
      tool.description.toLowerCase().includes(query) ||
      tool.tags?.some(tag => tag.toLowerCase().includes(query))
    );
  });

  // Score by relevance
  const scoredResults = results.map(tool => {
    let score = 0;
    
    // Exact name match gets highest score
    if (tool.name.toLowerCase() === query) score += 100;
    else if (tool.name.toLowerCase().startsWith(query)) score += 50;
    else if (tool.name.toLowerCase().includes(query)) score += 25;
    
    // Description match
    if (tool.description.toLowerCase().includes(query)) score += 10;
    
    // Tag match
    if (tool.tags?.some(tag => tag.toLowerCase().includes(query))) {
      score += 15;
    }

    return { ...tool, relevanceScore: score };
  });

  // Sort by relevance
  scoredResults.sort((a, b) => b.relevanceScore - a.relevanceScore);

  res.json({
    query: q,
    results: scoredResults.slice(0, parseInt(limit)),
    total: scoredResults.length
  });
});

// Get categories
app.get('/api/categories', ensureDataLoaded, (req, res) => {
  const categoriesWithCounts = Object.keys(toolsData.categories).map(categoryKey => {
    const count = toolsData.tools.filter(tool => 
      tool.category === categoryKey
    ).length;

    return {
      key: categoryKey,
      name: toolsData.categories[categoryKey],
      count: count
    };
  });

  res.json({
    categories: categoriesWithCounts,
    total: categoriesWithCounts.length
  });
});

// Get statistics
app.get('/api/stats', ensureDataLoaded, (req, res) => {
  const stats = {
    tools: {
      total: toolsData.tools.length,
      byCategory: {},
      byDifficulty: {},
      byTags: {}
    },
    categories: {
      total: Object.keys(toolsData.categories).length,
      list: Object.keys(toolsData.categories)
    },
    lastUpdate: lastUpdate?.toISOString(),
    metadata: toolsData.metadata
  };

  // Count by category
  toolsData.tools.forEach(tool => {
    stats.tools.byCategory[tool.category] = 
      (stats.tools.byCategory[tool.category] || 0) + 1;
  });

  // Count by difficulty
  toolsData.tools.forEach(tool => {
    if (tool.difficulty) {
      stats.tools.byDifficulty[tool.difficulty] = 
        (stats.tools.byDifficulty[tool.difficulty] || 0) + 1;
    }
  });

  // Count by tags
  toolsData.tools.forEach(tool => {
    if (tool.tags) {
      tool.tags.forEach(tag => {
        stats.tools.byTags[tag] = (stats.tools.byTags[tag] || 0) + 1;
      });
    }
  });

  res.json(stats);
});

// Get random tool
app.get('/api/random', ensureDataLoaded, (req, res) => {
  const { category, difficulty } = req.query;
  
  let eligibleTools = [...toolsData.tools];

  if (category) {
    eligibleTools = eligibleTools.filter(tool => 
      tool.category === category
    );
  }

  if (difficulty) {
    eligibleTools = eligibleTools.filter(tool => 
      tool.difficulty === difficulty
    );
  }

  if (eligibleTools.length === 0) {
    return res.status(404).json({ 
      error: 'No tools match the specified criteria' 
    });
  }

  const randomTool = eligibleTools[
    Math.floor(Math.random() * eligibleTools.length)
  ];

  res.json({
    tool: randomTool,
    message: '🎲 Random recommendation',
    criteria: { category, difficulty }
  });
});

// Install endpoint (returns command)
app.get('/api/install/:name', ensureDataLoaded, (req, res) => {
  const toolName = req.params.name.toLowerCase();
  const tool = toolsData.tools.find(t => 
    t.name.toLowerCase() === toolName
  );

  if (!tool) {
    return res.status(404).json({ 
      error: 'Tool not found' 
    });
  }

  res.json({
    tool: tool.name,
    command: tool.installation,
    instructions: [
      'Copy the command below',
      'Run it in your terminal',
      'Tool will be installed via Homebrew'
    ]
  });
});

// Bulk operations
app.post('/api/tools/bulk', ensureDataLoaded, (req, res) => {
  const { names } = req.body;

  if (!Array.isArray(names)) {
    return res.status(400).json({ 
      error: 'Request body must contain "names" array' 
    });
  }

  const results = names.map(name => {
    const tool = toolsData.tools.find(t => 
      t.name.toLowerCase() === name.toLowerCase()
    );
    return tool ? { found: true, ...tool } : { found: false, name };
  });

  res.json({
    requested: names.length,
    found: results.filter(r => r.found).length,
    results: results
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('❌ API Error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: err.message 
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Endpoint not found',
    availableEndpoints: '/api'
  });
});

// Start server
async function startServer() {
  try {
    await loadToolsData();
    
    app.listen(PORT, () => {
      console.log(`🚀 CLI Tools API Server running on port ${PORT}`);
      console.log(`📖 API Documentation: http://localhost:${PORT}/api`);
      console.log(`❤️  Health Check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 Received SIGINT, shutting down gracefully');
  process.exit(0);
});

startServer();
