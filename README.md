<div align="center">
  <h1>Reachy Mini SDK Claude Skill</h1>
  <a href="https://huggingface.co/spaces/pollen-robotics/Reachy_Mini"><img src="docs/assets/images/reachy_mini_dance.gif" alt="Reachy Mini dancing"/></a>
</div>



<p align="center">
    <strong>Comprehensive Claude Skill for programming Reachy Mini robots with Python SDK and REST API. Expert guidance for controlling Reachy Mini robots, integrating AI models, and building interactive applications with Claude AI.
</strong>
</p>

<p align="center">
    <a href="LICENSE.txt"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
    <a href="skill/references/openapi_schema.json"><img src="https://img.shields.io/badge/OpenAPI-3.1.0-green.svg" alt="OpenAPI"></a>
    <a href="https://github.com/pollen-robotics/reachy_mini"><img src="https://img.shields.io/badge/SDK-v1.2.6-orange.svg" alt="SDK Version"></a>
    <a href="https://claude.ai"><img src="https://img.shields.io/badge/Claude-Skills-purple.svg" alt="Claude Skills"></a>
    </br>
    <a href="https://github.com/jjmartres/reachy-mini-skill/issues"><img src="https://img.shields.io/github/issues/jjmartres/reachy-mini-skill" alt="GitHub Issues"/></a>
    <a href="https://github.com/jjmartres/reachy-mini-skill/pulls"><img src="https://img.shields.io/github/issues-pr/jjmartres/reachy-mini-skill" alt="GitHub Pull Requests"/></a>
</p>

---

## 🎯 Features

- **📚 Complete SDK Documentation** - Movement control, sensors, AI integration (240 lines, optimized)
- **🔌 REST API Reference** - 25+ FastAPI endpoints with detailed examples (500+ lines)
- **📋 OpenAPI Schema** - v3.1.0 specification for auto-generating clients in 50+ languages
- **🌐 Multi-Language Support** - Python, JavaScript, Go, Rust, and more via OpenAPI
- **🤖 AI Integration** - LLMs, vision models, multimodal applications, HuggingFace deployment
- **💡 Production-Ready Examples** - Real code samples and patterns
- **⚡️ Optimized for Claude** - Following official Anthropic guidelines (-50% token usage)

## 📦 Quick Start

### Option 1: Download Pre-built Skill (Recommended)

1. Go to [Releases](https://github.com/jjmartres/reachy-mini-sdkskill/releases)
2. Download `reachy-mini-sdk.skill`
3. In **Claude.ai**: Settings → Skills → Upload Skill
4. Select the downloaded file

### Option 2: Build from Source

```bash
# Clone repository
git clone https://github.com/jjmartres/reachy-mini-sdk-skill.git
cd reachy-mini-sdk-skill

# Initialize environment
make install

# Package the skill
make package

# Upload dist/reachy-mini-sdk.skill to Claude.ai
```

## 🚀 Usage with Claude

### Example Prompts

**Python SDK:**
```
Write code to make Reachy Mini wave hello and nod twice
```

**REST API:**
```
Show me how to control Reachy Mini from JavaScript using the REST API
```

**Web Dashboard:**
```
Create a React dashboard to monitor robot status in real-time
```

**AI Integration:**
```
Build an object detection app that makes Reachy wave when it sees a person
```

### OpenAPI Client Generation

Generate type-safe clients automatically:

```bash
# Python client
openapi-generator-cli generate \
  -i skill/references/openapi_schema.json \
  -g python \
  -o reachy-python-client/

# TypeScript types
openapi-typescript skill/references/openapi_schema.json -o reachy-types.ts

# Go client
openapi-generator-cli generate \
  -i skill/references/openapi_schema.json \
  -g go \
  -o reachy-go-client/
```

**50+ languages supported!**

## 📚 Documentation

### Skill Contents

| File | Description | Lines |
|------|-------------|-------|
| **SKILL.md** | Core guide (optimized) | 240 |
| **installation.md** | Setup for all platforms | 150 |
| **movement_control.md** | Complete movement guide | 450+ |
| **sensors.md** | Camera, microphone, IMU | 200 |
| **ai_integration.md** | AI models and apps | 300 |
| **daemon_api.md** | REST API reference | 500+ |
| **openapi_schema.json** | OpenAPI v3.1.0 spec | Full |
| **openapi_usage.md** | Client generation guide | 200 |
| **api_quick_reference.md** | Quick lookup | 150 |

## 🤖 What is Reachy Mini?

Reachy Mini is an **open-source desktop humanoid robot** by [Pollen Robotics](https://pollen-robotics.com):

- **6-DOF Head** - Stewart platform for natural movement
- **Expressive Antennas** - Two servos for emotions
- **360° Body Rotation** - Full rotation capability
- **HD Camera** - Computer vision ready
- **Microphone & Speaker** - Voice interaction
- **Python SDK** - High-level control
- **REST API** - HTTP control from any language
- **HuggingFace Integration** - Deploy AI apps

🛒 [Buy Reachy Mini](https://hf.co/reachy-mini) | 📖 [Official SDK](https://github.com/pollen-robotics/reachy_mini)

## 💻 Supported Languages

- Python (SDK + REST API)
- JavaScript/TypeScript
- Go
- Rust  
- Java/Kotlin
- Swift
- PHP, Ruby, C#, C++
- **40+ more** via OpenAPI Generator

## 🎨 What Can You Build?

### AI Applications
- Conversational robots with LLMs
- Object detection and tracking
- Face recognition
- Voice assistants
- Multimodal AI systems

### Interactive Apps
- Web dashboards
- Mobile apps (iOS/Android)
- Desktop applications
- Home automation
- Monitoring systems

### Research & Education
- Human-robot interaction
- Robotics education
- AI experimentation
- STEM demonstrations

## 🛠️ Development

### Prerequisites

- Python 3.12+
- Claude.ai account
- (Optional) OpenAPI Generator

### Build Instructions

```bash
# Clone repository
git clone https://github.com/jjmartres/reachy-mini-sdk-skill.git
cd reachy-mini-sdk-skill

# Initialize environment
make install

# Validate
make validate

# Package
make package

# Output: dist/reachy-mini-sdk.skill
```

### Repository Structure

```
reachy-mini-sdk-skill/
├── skill/                    # Skill source
│   ├── SKILL.md              # Main file (240 lines)
│   ├── NETADATA.yaml         # Skill metadata
│   └── references/           # References
├── scripts/                  # Build scripts
│   ├── package_skill.py
│   └── quick_validate.py
├── dist/                     # Build output
│   └── reachy-mini-sdk.skill
├── LICENSE      
├── README.md
└── CONTRIBUTING.md
```

## 📊 Optimization

Follows **official Anthropic guidelines**:

- ✅ **50% smaller** SKILL.md (487 → 240 lines)
- ✅ **"Concise is Key"** principle
- ✅ **Progressive disclosure** pattern
- ✅ **Proper metadata** structure
- ✅ **Token efficient** (~2,200 vs ~4,500 tokens)

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

**Ideas:**
- Add examples in new languages
- Improve documentation
- Report bugs
- Share projects

## 🙏 Acknowledgments

- **[Pollen Robotics](https://pollen-robotics.com)** - Reachy Mini creators
- **[Anthropic](https://anthropic.com)** - Claude AI platform
- **Community** - Feedback and contributions

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/jjmartres/reachy-mini-sdk-skill/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jjmartres/reachy-mini-sdk-skill/discussions)

## 🔗 Links

- [Reachy Mini SDK](https://github.com/pollen-robotics/reachy_mini)
- [Reachy Mini Hub](https://hf.co/reachy-mini)
- [OpenAPI Spec](https://spec.openapis.org/oas/v3.1.0)
- [Anthropic Skills](https://github.com/anthropics/skills)

## 📈 Changelog

[CHANGELOG](CHANGELOG.md)
---

**⭐ Star this repo if you find it helpful!**

Made with ❤️ by [Jean-Jacques Martres](https://github.com/jjmartres)
