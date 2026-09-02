// 裁剪 pi 内置 openrouter provider：只保留 reasonix 配置的模型（其余 340+ 个 openrouter 模型不在此列出）。
// registerProvider 的 models 是替换语义，会覆盖 pi 内置 openrouter 目录。
// 模型定义从 pi 内置 models-store 提取，保持与 reasonix 配置的 openrouter 模型一一对应。
export default function (pi) {
  pi.registerProvider("openrouter", {
    name: "OpenRouter",
    baseUrl: "https://openrouter.ai/api/v1",
    api: "openai-completions",
    apiKey: "$OPENROUTER_API_KEY",
    models: [
  {
    "id": "openrouter/free",
    "name": "Free Models Router",
    "reasoning": true,
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 200000,
    "maxTokens": 4096,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "google/gemma-4-26b-a4b-it:free",
    "name": "Google: Gemma 4 26B A4B  (free)",
    "reasoning": true,
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 262144,
    "maxTokens": 32768,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "google/gemma-4-31b-it:free",
    "name": "Google: Gemma 4 31B (free)",
    "reasoning": true,
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 262144,
    "maxTokens": 32768,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "cohere/north-mini-code:free",
    "name": "Cohere: North Mini Code (free)",
    "reasoning": true,
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 256000,
    "maxTokens": 64000,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "nvidia/nemotron-3-super-120b-a12b:free",
    "name": "NVIDIA: Nemotron 3 Super (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": "none",
      "minimal": null,
      "low": "low",
      "medium": "medium",
      "high": null,
      "xhigh": null,
      "max": null
    },
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 262144,
    "maxTokens": 235929,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
    "name": "NVIDIA: Nemotron 3 Nano Omni (free)",
    "reasoning": true,
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 256000,
    "maxTokens": 65536,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "nvidia/nemotron-3-ultra-550b-a55b:free",
    "name": "NVIDIA: Nemotron 3 Ultra (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": "none",
      "minimal": null,
      "low": null,
      "medium": "medium",
      "high": "high",
      "xhigh": null,
      "max": null
    },
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 1000000,
    "maxTokens": 65536,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "nvidia/nemotron-3.5-lightning:free",
    "name": "NVIDIA: Nemotron 3.5 Lightning (free)",
    "reasoning": true,
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 1000000,
    "maxTokens": 65536,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "liquid/lfm-2.5-2.6b:free",
    "name": "LiquidAI: LFM2.5-2.6B (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": null
    },
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 65536,
    "maxTokens": 8192,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "thinkingmachines/inkling-small:free",
    "name": "Thinking Machines: Inkling Small (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": "none",
      "minimal": "minimal",
      "low": "low",
      "medium": "medium",
      "high": "high",
      "xhigh": null,
      "max": "max"
    },
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 1048576,
    "maxTokens": 262144,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "thinkingmachines/inkling:free",
    "name": "Thinking Machines: Inkling (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": "none",
      "minimal": "minimal",
      "low": "low",
      "medium": "medium",
      "high": "high",
      "xhigh": null,
      "max": "max"
    },
    "input": [
      "text",
      "image"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 1048576,
    "maxTokens": 262144,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "poolside/laguna-s-2.1:free",
    "name": "Poolside: Laguna S 2.1 (free)",
    "reasoning": true,
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 262144,
    "maxTokens": 32768,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "poolside/laguna-xs-2.1:free",
    "name": "Poolside: Laguna XS 2.1 (free)",
    "reasoning": true,
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 262144,
    "maxTokens": 32768,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  },
  {
    "id": "z-ai/glm-5.2:free",
    "name": "Z.ai: GLM 5.2 (free)",
    "reasoning": true,
    "thinkingLevelMap": {
      "off": "none",
      "minimal": null,
      "low": null,
      "medium": null,
      "high": "high",
      "xhigh": "xhigh",
      "max": null
    },
    "input": [
      "text"
    ],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": 256000,
    "maxTokens": 230400,
    "compat": {
      "supportsDeveloperRole": false,
      "thinkingFormat": "openrouter"
    }
  }
]
  });
}
