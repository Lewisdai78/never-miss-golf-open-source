import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Never Miss Golf — A private wrist reminder for your round",
  description:
    "Save a course on your iPhone, get a private Apple Watch reminder, and choose when to open Golf in Apple Workout.",
};

export default function Home() {
  return (
    <main>
      <nav className="nav" aria-label="Primary navigation">
        <a className="brand" href="#top" aria-label="Never Miss Golf home">
          <span className="brand-mark" aria-hidden="true">●</span>
          NEVER MISS GOLF
        </a>
        <div className="nav-links">
          <a href="#flow">How it works</a>
          <a href="#privacy">Privacy</a>
          <a href="#source">Source</a>
        </div>
      </nav>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow"><span /> iPhone + Apple Watch prototype</p>
          <h1>Arrive at the course.<br /><em>Remember the workout.</em></h1>
          <p className="lede">
            Never Miss Golf keeps one small promise: after you stay near a course you saved,
            it gives your wrist a quiet nudge. You decide what happens next.
          </p>
          <div className="hero-actions">
            <a className="button primary" href="#flow">See the flow <span aria-hidden="true">↓</span></a>
            <a className="button secondary" href="https://github.com/Lewisdai78/never-miss-golf-open-source">View source</a>
          </div>
          <ul className="trust-row" aria-label="Product principles">
            <li>On device</li><li>No account</li><li>No GPS history</li><li>Never auto-starts</li>
          </ul>
        </div>

        <div className="device-stage" aria-label="Illustration of the iPhone and Apple Watch experience">
          <div className="course-orbit orbit-one" /><div className="course-orbit orbit-two" />
          <div className="phone">
            <div className="phone-island" />
            <div className="phone-screen">
              <div className="app-bar"><span>‹</span><b>GOLF NEVER MISS</b><span className="status-dot" /></div>
              <div className="hero-card">
                <small>● COURSE REMINDERS READY</small>
                <strong>When you arrive,<br />don’t miss<br />Golf Workout</strong>
                <span>1 of 3 courses saved</span>
              </div>
              <div className="status-panel">
                <p>PERMISSIONS &amp; STATUS</p>
                <div><span className="mini-icon">↗</span><b>Location</b><i /></div>
                <div><span className="mini-icon">◉</span><b>Reminders</b><i /></div>
              </div>
              <div className="course-panel"><span>⚑</span><div><b>My saved course</b><small>Stored only on this iPhone</small></div></div>
            </div>
          </div>
          <div className="watch">
            <div className="watch-crown" />
            <div className="watch-screen">
              <div className="watch-icon">⚑</div>
              <b>Ready to<br />play golf?</b>
              <small>It looks like you’ve been at a saved course for a little while.</small>
              <span className="watch-action">Open Workout</span>
              <span className="watch-alt">Not today · Snooze 10 min</span>
            </div>
          </div>
          <div className="signal-chip">PRIVATE · LOCAL · ON DEVICE</div>
        </div>
      </section>

      <section className="flow-section" id="flow">
        <div className="section-heading">
          <p className="eyebrow"><span /> A deliberately small product</p>
          <h2>One reminder.<br />Three human decisions.</h2>
          <p>The app never guesses that you are playing. It waits, asks, and leaves the final action to you.</p>
        </div>
        <div className="flow-grid">
          <article><span className="step">01</span><div className="step-visual pin"><i /><i /><i /></div><h3>Save a course</h3><p>Keep up to three course centers on your iPhone. No map history, route, or cloud account.</p></article>
          <article><span className="step">02</span><div className="step-visual pulse"><i /><i /><b>⚑</b></div><h3>Get a wrist reminder</h3><p>After the device detects a qualifying stay, a local notification can reach your Apple Watch.</p></article>
          <article><span className="step">03</span><div className="step-visual choices"><b>Open Workout</b><span>Not today</span><span>Snooze 10 min</span></div><h3>You choose</h3><p>Open Apple Workout, dismiss the visit, or ask again later. Nothing starts silently.</p></article>
        </div>
      </section>

      <section className="boundary-section">
        <div className="boundary-copy">
          <p className="eyebrow light"><span /> The honest Apple boundary</p>
          <h2>A reminder can open the door.<br />It cannot play the round for you.</h2>
          <p>
            Never Miss Golf requests the handoff to Apple’s built-in Golf workout. The user still confirms the
            reminder and taps Start inside Apple Workout. The prototype does not silently control Apple Workout.
          </p>
        </div>
        <div className="boundary-flow" aria-label="Product handoff sequence">
          <div><small>NEVER MISS GOLF</small><b>Ready to play golf?</b><span>Open Workout</span></div>
          <i aria-hidden="true">→</i>
          <div><small>APPLE WORKOUT</small><b>Golf</b><span className="play">▶</span></div>
          <i aria-hidden="true">→</i>
          <div className="human"><small>USER ACTION</small><b>Tap to start</b><span>Required</span></div>
        </div>
      </section>

      <section className="privacy-section" id="privacy">
        <div className="privacy-card">
          <div className="lock" aria-hidden="true"><span /></div>
          <p className="eyebrow"><span /> Privacy by absence</p>
          <h2>There is almost nothing to steal.</h2>
          <p>Course data stays inside the app container on your iPhone. The prototype has no business server, account system, advertising, or analytics SDK.</p>
        </div>
        <div className="privacy-list">
          <div><span>✓</span><b>One center point</b><p>Only the course location you choose—not your path there or away.</p></div>
          <div><span>✓</span><b>Local reminder state</b><p>Just enough state to avoid repeatedly nudging you during the same visit.</p></div>
          <div><span>—</span><b>No health-data access</b><p>The prototype does not read or write workout, heart-rate, or calorie data.</p></div>
          <div><span>×</span><b>No cloud trail</b><p>No account, remote database, analytics event stream, or continuous GPS log.</p></div>
        </div>
      </section>

      <section className="source-section" id="source">
        <div>
          <p className="eyebrow"><span /> Built in public, released with care</p>
          <h2>Open enough to learn from.<br />Private enough to be safe.</h2>
        </div>
        <div className="source-copy">
          <p>
            The public repository contains the iOS and watchOS source, project configuration, state-machine tests,
            privacy documentation and reproducible safety checks. Signing credentials, real coordinates, device data,
            private configuration and development history are intentionally excluded.
          </p>
          <a className="button primary" href="https://github.com/Lewisdai78/never-miss-golf-open-source">Open GitHub ↗</a>
        </div>
      </section>

      <section className="status-section">
        <p className="eyebrow"><span /> Prototype status</p>
        <div className="status-grid">
          <div><b>Built</b><p>Native iOS and watchOS prototype</p></div>
          <div><b>Tested</b><p>Home-simulated end-to-end device flow</p></div>
          <div><b>Pending</b><p>Repeated on-course arrival validation</p></div>
          <div><b>Not claimed</b><p>Automatic workout start or production reliability</p></div>
        </div>
      </section>

      <footer>
        <a className="brand" href="#top"><span className="brand-mark" aria-hidden="true">●</span> NEVER MISS GOLF</a>
        <p>A private, user-confirmed golf reminder prototype.</p>
        <a href="https://github.com/Lewisdai78">Built by @Lewisdai78</a>
      </footer>
    </main>
  );
}
