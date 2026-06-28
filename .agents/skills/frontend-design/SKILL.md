---
name: frontend-design
description: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults.
license: Complete terms in LICENSE.txt
---

# Frontend Design

Approach this as the design lead at a small studio known for giving every client a visual identity that could not be mistaken for anyone else's. This client has already rejected proposals that felt templated, and is paying for a distinctive point of view: make deliberate, opinionated choices about palette, typography, and layout that are specific to this brief, and take one real aesthetic risk you can justify.

## Ground it in the subject

If the brief does not pin down what the product or subject is, pin it yourself before designing: name one concrete subject, its audience, and the page's single job, and state your choice. If there's any information in your memory about the human's preferences, context about what they're building, or designs you've made before use that as a hint. The subject's own world, its materials, instruments, artifacts, and vernacular, is where distinctive choices come from. Build with the brief's real content and subject matter throughout.

## Design principles

For web designs, the hero is a thesis. Open with the most characteristic thing in the subject's world, in whatever form makes sense for it: a headline, an image, an animation, a live demo, an interactive moment. Be deliberate with your choice: a big number with a small label, supporting stats, and a gradient accent is the template answer, only use if that is truly the best option.

Typography carries the personality of the page. Pair the display and body faces deliberately, not the same families you would reach for on any other project, and set a clear type scale with intentional weights, widths, and spacing. Make the type treatment itself a memorable part of the design, not a neutral delivery vehicle for the content.

Structure is information. Structural devices, numbering, eyebrows, dividers, labels, should encode something true about the content, not decorate it.

Leverage motion deliberately. Think about where and if animation can serve the subject: a page-load sequence, a scroll-triggered reveal, hover micro-interactions, ambient atmosphere. An orchestrated moment usually lands harder than scattered effects. However, sometimes less is more, and extra animation contributes to the feeling that the design is AI-generated.

Match complexity to the vision. Maximalist directions need elaborate execution; minimal directions need precision in spacing, type, and detail. Elegance is executing the chosen vision well.

## Design languages to study

### Claude Design Language (Anthropic)

Claude sets the standard for warm, intelligent interface design. Study it for applications where approachability, trust, and clarity matter.

#### Signature moves

A warm cream (near #F4F1EA) or cool off-white canvas. Deep charcoal text with a single warm accent used sparingly (an amber button, a terracotta link, a sage divider). Typography carries the brand more than layout geometry does. Generous whitespace both inside and between elements. Cards and panels feel like they belong to the page, not floating above it zero elevation is the goal, not glassmorphism. The layout is usually centered or left-biased with a constrained measure, never full-bleed just because.

#### Color system

Canvas warm: #F4F1EA (cream), #FCFAF5 (warm white), #FFFFFF (pure white cards). Text: #1A1A1A (headings), #2D2D2D (body), #6B7280 (muted). Accent: #D97706 (amber), #B45309 (dark amber), #8B9D83 (sage), #6B7B63 (dark sage). Borders and dividers: #E5E2DA (warm gray), rgba(0,0,0,0.06). Errors: #DC2626 (red, used plainly). Surfaces: flat background, cards use white with 1px warm border and very soft shadow (0 1px 3px rgba(0,0,0,0.06)).

#### Typography

Geometric sans for both display and body: Inter, Plus Jakarta Sans, or Outfit. Keep the pairing within one family use weight and size for hierarchy, not a second face. Code blocks use Geist Mono or JetBrains Mono. Scale: 13-14px body, 16px large body, 20-24px small headings, 32-48px section headings, 56-72px hero display. Letter-spacing defaults to 0 or very tight. Use font-weight for hierarchy: 400 body, 500 emphasized body, 600 small headings, 700 large headings.

#### Layout patterns

Constrained max-width (680-760px for reading content, 1024-1200px for app layouts). Vertical rhythm with generous padding between sections (80-120px). Cards use 12px border-radius with 1px border. Content is centered with even gutters. Two-column layouts only when justified by content comparison or form input. Modals and overlays are centered, not full-screen.

#### UI details

Buttons: filled with accent color, 8-12px radius, no icon unless essential. Outlines use 1.5px stroke. Shadows are subtle (0 1px 2px). Hover elevates 1-2px with deeper shadow. Focus rings use accent color with 2px offset. Inputs have clean bordered style with subtle focus ring. Transitions run 150-200ms ease. Empty states are instructional, not decorative. Toast notifications use the same warm canvas with a left border accent.

#### When to use this language

Productivity tools, SaaS dashboards, documentation, AI chat interfaces, professional tools, content-heavy applications. Anywhere the user needs to trust the interface and focus on their work.

--- 

### MiniMax M3 Design Language

MiniMax M3 defines the cinematic, immersive design language for entertainment and media. Study it for applications where spectacle, emotion, and visual impact matter.

#### Signature moves

Near-black canvas (#0A0A0A to #141414). Vibrant gradients that sweep across the page purple-magenta-cyan or deep blue-teal. Glassmorphism used as a deliberate accent, not a surface default. Full-bleed media backgrounds with gradient overlays. Typography uses extreme contrast: razor-thin body weights next to bold, tracking-tight headlines. Layered depth through overlapping elements, glowing borders, and dramatic hover transforms. The layout breathes asymmetry and purposeful imbalance.

#### Color system

Canvas: #0A0A0A, #0D0D0D, #141414. Gradients: purple (#7C3AED) through magenta (#EC4899) to cyan (#06B6D4), or deep navy (#1E3A5F) to teal (#0D9488). Accent: #FF3366 (neon red), #00FFAA (neon green), #6644FF (neon purple), #FF6B35 (neon orange). Text: #FFFFFF primary, #A0A0A0 secondary, #555555 muted. Surfaces: rgba(255,255,255,0.05) to rgba(255,255,255,0.10) with backdrop blur(12-20px). Borders: rgba(255,255,255,0.08) to rgba(255,255,255,0.15). Glow: box-shadow with accent color at 20-40px blur.

#### Typography

Bold display faces for headlines: Instrument Sans Bold, Work Sans ExtraBold, or Bricolage Grotesque Bold. Body uses lighter weights of the same or complementary family. Code uses JetBrains Mono or Geist Mono. Scale: 13-14px body, 24-32px small headings, 48-64px section headings, 72-96px hero display. Letter-spacing is tight for headlines (-0.02 to -0.03em), wide for uppercase labels (0.08-0.15em). Line-height is tight for display (0.95-1.05), generous for body (1.6-1.7).

#### Layout patterns

Full-bleed hero sections with no container constraint. Asymmetric grids: 60/40 splits, overlapping zones, content that breaks out of its column. Large media-first areas where posters, videos, or images occupy the primary viewport. Z-layered composition with elements on different depth planes. Cards float with shadow and subtle glow. Sections feel like scenes, not rows.

#### UI details

Glass panels: background rgba(255,255,255,0.05-0.10) with backdrop-filter blur(16px). Borders glow with accent color on hover. Buttons have gradient backgrounds, subtle text-shadow, and glow on hover. Inputs: dark background, bordered with low-opacity white, focus glow instead of ring. Hover states are dramatic: scale(1.02-1.05) + enhanced glow + border brightening. Navigation uses glassmorphism with blur. Transitions run 250-350ms with eased curves. Loading states use shimmer gradients. Empty states use ambient animation.

#### Signature visual effects

Gradient mesh backgrounds that animate slowly. Noise/grain texture overlaid on gradients. Full-bleed image or video backgrounds with gradient overlays (dark at edges, clear at focal point). Glowing dot or line accents. Particle effects for hero sections. Card stacks with z-depth and parallax. Entry animations: elements rise into place with slight overshoot. Text reveals with gradient sweep or clip animation.

#### When to use this language

Entertainment platforms, media streaming, gaming dashboards, creative tools, portfolio sites, product showcases, launch pages. Anywhere the experience itself is part of the product.

---

## Choosing between them

Ask these questions to decide which pole to lean toward:

Is the user here to do work or to feel something? Claude for work, MiniMax for feeling.

Is the primary content text or media? Claude for text, MiniMax for media.

Does the interface need to get out of the way or make an entrance? Claude gets out of the way, MiniMax makes an entrance.

Is the brand voice calm and capable or ambitious and exciting? Claude for calm capable, MiniMax for ambitious exciting.

---

## Blending the two languages

Some of the strongest designs borrow from both. Here is how to blend them deliberately:

Start with Claude's layout discipline (constrained measure, generous whitespace, clear hierarchy) but use MiniMax's color confidence (dark canvas, one vibrant gradient accent, strategic glow). Or start with MiniMax's immersive structure (full-bleed hero, asymmetric grid) but apply Claude's typographic restraint and reduced shadow complexity. The hybrid works best when one language leads and the other serves as an accent never a 50/50 split.

Examples of good blends: A dark-mode SaaS that uses MiniMax's glassmorphism for the nav but Claude's clean card layout for content. A media platform that uses Claude's warm cream background and generous spacing but MiniMax's gradient accent on the hero and player controls.

---

## Process: brainstorm, explore, plan, critique, build, critique again

For calibration: AI-generated design right now clusters around three looks: (1) a warm cream background near F4F1EA with a high-contrast serif display and a terracotta accent; (2) a near-black background with a single bright acid-green or vermilion accent; (3) a broadsheet-style layout with hairline rules, zero border-radius, and dense newspaper-like columns. All three are legitimate for some briefs, but they are defaults rather than choices. Where the brief pins down a visual direction, follow it exactly. Where it leaves an axis free, do not spend that freedom on one of these defaults.

Work in two passes. First, brainstorm a short design plan based on the human's design brief: create a compact token system with color, type, layout, and signature. Color: describe the palette as 4-6 named hex values. Type: the typefaces for 2+ roles (a characterful display face used with restraint, a complementary body face, and a utility face for captions if needed). Layout: a layout concept using one-sentence prose descriptions and ASCII wireframes. Signature: the single unique element this page will be remembered by.

Then review that plan against the brief before building: if any part reads like a generic default rather than a choice made for this specific brief, revise that part, say what you changed and why. Only after confirming the relative uniqueness of your design plan should you start writing code, following the revised plan exactly.

When writing the code, be careful of structuring your CSS selector specificities. It is easy to generate CSS classes that cancel each other out. This can happen often with paddings and margins between sections.

Try to do a lot of this planning and iteration in your thinking, and only show ideas to the user when you have higher confidence it will delight them.

## Restraint and self-critique

Spend your boldness in one place. Let the signature element be the one memorable thing, keep everything around it quiet and disciplined, and cut any decoration that does not serve the brief. Not taking a risk can be a risk itself. Build to a quality floor without announcing it: responsive down to mobile, visible keyboard focus, reduced motion respected. Critique your own work as you build, taking screenshots if your environment supports it a picture is worth 1000 tokens. Consider Chanel advice: before leaving the house, take a look in the mirror and remove one accessory.

## More on writing in design

Words appear in a design for one reason: to make it easier to understand, and therefore easier to use. They are design material, not decoration. Bring the same intentionality to copy that you would bring to spacing and color. Before writing anything, ask what the design needs to say, and how it can best be said to help the person navigate the experience.

Write from the end user side of the screen. Name things by what people control and recognize, never by how the system is built. A person manages notifications, not webhook config. Describe what something does in plain terms rather than selling it. Being specific is always better than being clever.

Use active voice as default. A control should say exactly what happens when it is used: Save changes, not Submit. An action keeps the same name through the whole flow, so the button that says Publish produces a toast that says Published. The vocabulary of an interface is the signposting for someone navigating the product. Cohesion and consistency are how people learn their way around.

Treat failure and emptiness as moments for direction, not mood. Explain what went wrong and how to fix it, in the interface voice rather than a person voice. Errors do not apologize, and they are never vague about what happened. An empty screen is an invitation to act.

Keep the register conversational and tuned: plain verbs, sentence case, no filler, with tone matched to the brand and the audience. Let each element do exactly one job. A label labels, an example demonstrates, and nothing quietly does double duty.
