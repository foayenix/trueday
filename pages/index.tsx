import Head from 'next/head';
import { FormEvent, useState } from 'react';

type SubmissionStatus = 'idle' | 'loading' | 'success' | 'error';

type WaitlistFormProps = {
  variant?: 'hero' | 'cta';
};

const WaitlistForm = ({ variant = 'hero' }: WaitlistFormProps) => {
  const [status, setStatus] = useState<SubmissionStatus>('idle');
  const [message, setMessage] = useState('');

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    if (typeof window === 'undefined') {
      return;
    }

    event.preventDefault();
    setStatus('loading');
    setMessage('');

    const form = event.currentTarget;
    const formData = new FormData(form);
    const payload = new URLSearchParams();
    formData.forEach((value, key) => {
      if (typeof value === 'string') {
        payload.append(key, value);
      }
    });
    try {
      const response = await fetch('/api/waitlist', {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
        },
        body: payload,
      });

      if (!response.ok) {
        throw new Error('Request failed');
      }

      form.reset();
      setStatus('success');
      setMessage("You're on the list.");
    } catch (error) {
      console.error(error);
      setStatus('error');
      setMessage('Something went wrong. Please try again.');
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      method="post"
      action="/api/waitlist"
      className="space-y-4"
    >
      <div className="space-y-2">
        <label htmlFor={`email-${variant}`} className="text-sm font-semibold text-slate-200">
          Email
        </label>
        <input
          id={`email-${variant}`}
          name="email"
          type="email"
          required
          className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-base text-white placeholder:text-slate-400 focus:border-indigo-400 focus:outline-none focus:ring-2 focus:ring-indigo-400/60"
          placeholder="you@example.com"
        />
      </div>
      <div className="space-y-2">
        <label htmlFor={`role-${variant}`} className="text-sm font-semibold text-slate-200">
          I am a...
        </label>
        <select
          id={`role-${variant}`}
          name="role"
          required
          className="w-full appearance-none rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-base text-white focus:border-indigo-400 focus:outline-none focus:ring-2 focus:ring-indigo-400/60"
          defaultValue=""
        >
          <option value="" disabled>
            Select an option
          </option>
          <option value="Practitioner / clinic">Practitioner / clinic</option>
          <option value="Researcher / institution">Researcher / institution</option>
          <option value="Wellness client / interested">Wellness client / interested</option>
        </select>
      </div>
      <button
        type="submit"
        className="w-full rounded-xl bg-gradient-to-r from-indigo-500 via-purple-500 to-indigo-400 px-6 py-3 text-base font-semibold text-white transition hover:shadow-lg hover:shadow-indigo-500/30 focus:outline-none focus:ring-2 focus:ring-indigo-400/70 focus:ring-offset-2 focus:ring-offset-slate-950"
        disabled={status === 'loading'}
      >
        {status === 'loading' ? 'Submitting...' : 'Join Waitlist'}
      </button>
      <p className="text-sm text-slate-300">No spam. You’ll be first to know when we launch.</p>
      <div aria-live="polite" className="text-sm font-semibold text-emerald-300">
        {status === 'success' ? message : null}
      </div>
      <div aria-live="assertive" className="text-sm font-semibold text-rose-300">
        {status === 'error' ? message : null}
      </div>
    </form>
  );
};

const IndexPage = () => {
  return (
    <>
      <Head>
        <title>SANA | Evidence-based wellness platform</title>
        <meta
          name="description"
          content="SANA is the operating system for Complementary & Alternative Medicine practitioners. Join the waitlist to manage your practice and prove outcomes."
        />
      </Head>
      <div className="min-h-screen bg-gradient-to-b from-slate-950 via-slate-950 to-slate-900 font-sans text-slate-100">
        <header className="sticky top-0 z-50 border-b border-white/5 bg-slate-950/80 backdrop-blur">
          <nav className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
            <a href="#top" className="text-lg font-semibold tracking-wide">
              <span className="bg-gradient-to-r from-indigo-400 via-purple-400 to-indigo-300 bg-clip-text text-transparent">
                SANA
              </span>
            </a>
            <div className="hidden items-center gap-8 text-sm font-medium text-slate-200 md:flex">
              <a href="#why" className="transition hover:text-white">
                Why SANA
              </a>
              <a href="#practitioners" className="transition hover:text-white">
                For Practitioners
              </a>
              <a href="#evidence" className="transition hover:text-white">
                Evidence
              </a>
              <a
                href="#waitlist"
                className="rounded-full border border-indigo-400/60 px-4 py-2 text-indigo-200 transition hover:border-indigo-300 hover:text-white"
              >
                Join Waitlist
              </a>
            </div>
            <a
              href="#waitlist"
              className="inline-flex items-center rounded-full border border-indigo-400/60 px-4 py-2 text-sm font-semibold text-indigo-200 transition hover:border-indigo-300 hover:text-white md:hidden"
            >
              Join Waitlist
            </a>
          </nav>
        </header>

        <main id="top" className="mx-auto flex max-w-6xl flex-col gap-24 px-6 pb-24 pt-16">
          <section className="grid gap-12 lg:grid-cols-2 lg:items-center">
            <div className="max-w-xl space-y-8">
              <div className="space-y-4">
                <h1 className="text-3xl font-bold leading-tight text-white sm:text-4xl lg:text-5xl">
                  Evidence-based wellness starts here.
                </h1>
                <p className="text-lg text-slate-300">
                  Practice management, client outcomes, and credibility — all in one platform.
                </p>
                <ul className="space-y-3 text-base text-slate-200">
                  {[
                    'Booking, payments, notes in one place',
                    'Track client progress over time',
                    'Show proof your work is effective',
                  ].map((item) => (
                    <li key={item} className="flex items-start gap-3">
                      <span className="mt-1 inline-flex h-5 w-5 items-center justify-center rounded-full bg-indigo-500/40 text-sm text-indigo-100">
                        ✓
                      </span>
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
              <div className="rounded-2xl border border-white/10 bg-slate-900/60 p-6 shadow-lg shadow-indigo-500/10 backdrop-blur">
                <WaitlistForm />
              </div>
            </div>
            <div className="lg:justify-self-end">
              <div className="relative mx-auto max-w-md rounded-3xl border border-white/10 bg-white/5 p-6 shadow-[0_0_60px_-20px_rgba(99,102,241,0.7)] backdrop-blur">
                <div className="absolute inset-0 -z-10 rounded-3xl bg-gradient-to-br from-purple-500/20 via-indigo-500/10 to-transparent" />
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <p className="text-sm font-semibold text-slate-200">Today’s sessions</p>
                    <span className="rounded-full bg-emerald-400/20 px-3 py-1 text-xs font-medium text-emerald-200">
                      Active
                    </span>
                  </div>
                  <div className="rounded-2xl border border-white/10 bg-slate-900/60 p-4">
                    <p className="text-sm text-slate-300">Client outcome trend</p>
                    <p className="mt-2 text-2xl font-semibold text-emerald-300">↑ 12%</p>
                    <p className="mt-4 text-sm text-slate-400">
                      Week-over-week improvement across mood, sleep, and energy.
                    </p>
                  </div>
                  <div className="rounded-2xl border border-white/10 bg-slate-900/60 p-4">
                    <p className="text-sm text-slate-300">Credibility score</p>
                    <p className="mt-2 text-2xl font-semibold text-indigo-200">86 / 100</p>
                    <p className="mt-4 text-sm text-slate-400">
                      Based on verified outcomes, adherence, and credentials.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section id="why" className="space-y-12">
            <div className="max-w-xl space-y-4">
              <h2 className="text-3xl font-semibold text-white sm:text-4xl">
                Wellness is booming. Trust isn’t.
              </h2>
              <p className="text-lg text-slate-300">
                Practitioners deliver life-changing care, but fragmented systems make it hard to operate and prove value.
              </p>
            </div>
            <div className="grid gap-6 md:grid-cols-3">
              {[
                {
                  title: 'Admin chaos',
                  description:
                    'Most practitioners are stitching together Calendly, Stripe, email, WhatsApp, and paper notes.',
                },
                {
                  title: 'No proof',
                  description:
                    'You help clients feel better — but you have no way to show outcomes in real numbers.',
                },
                {
                  title: 'Low credibility',
                  description:
                    'Clients can’t tell who’s qualified and who’s not. That kills referrals and blocks you from corporate/NHS work.',
                },
              ].map((item) => (
                <div
                  key={item.title}
                  className="rounded-2xl border border-white/10 bg-slate-900/50 p-6 shadow-lg shadow-purple-500/10 backdrop-blur"
                >
                  <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-full bg-indigo-500/20 text-indigo-200">
                    <span className="text-xl">●</span>
                  </div>
                  <h3 className="text-xl font-semibold text-white">{item.title}</h3>
                  <p className="mt-3 text-sm text-slate-300">{item.description}</p>
                </div>
              ))}
            </div>
          </section>

          <section id="practitioners" className="space-y-12">
            <div className="max-w-2xl space-y-4">
              <h2 className="text-3xl font-semibold text-white sm:text-4xl">
                Run your practice like a clinic. Prove your impact like a researcher.
              </h2>
            </div>
            <div className="grid gap-6 md:grid-cols-3">
              {[
                {
                  title: 'All-in-one practice hub',
                  description:
                    'Bookings, secure notes, messaging, payments, telehealth — in one dashboard.',
                  badge: 'Replace 5+ tools',
                },
                {
                  title: 'Client progress tracking',
                  description:
                    'Track mood, sleep, pain, energy and see improvement over time — visualised for you and your client.',
                  badge: 'Retention driver',
                },
                {
                  title: 'Credibility score',
                  description:
                    'We generate an evidence score based on outcomes, consistency, and verified credentials. This builds trust with clients, employers, and insurers.',
                  badge: 'Professional proof',
                },
              ].map((feature) => (
                <div
                  key={feature.title}
                  className="flex flex-col gap-4 rounded-2xl border border-white/10 bg-slate-900/50 p-6 shadow-lg shadow-indigo-500/10 backdrop-blur"
                >
                  <span className="self-start rounded-full border border-indigo-400/50 bg-indigo-500/10 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-indigo-200">
                    {feature.badge}
                  </span>
                  <h3 className="text-xl font-semibold text-white">{feature.title}</h3>
                  <p className="text-sm text-slate-300">{feature.description}</p>
                </div>
              ))}
            </div>
          </section>

          <section className="space-y-12">
            <div className="max-w-xl space-y-4">
              <h2 className="text-3xl font-semibold text-white sm:text-4xl">
                Built with practitioners, not for them.
              </h2>
            </div>
            <div className="grid gap-6 md:grid-cols-3">
              {[
                {
                  quote: '“If this existed last year I would’ve saved 10 hours a week.”',
                  name: '– Registered Medical Herbalist, London',
                },
                {
                  quote:
                    '“My biggest problem is proving outcomes. If SANA can document results automatically, I can finally approach corporate clients.”',
                  name: '– Nutritionist, Bristol',
                },
                {
                  quote:
                    '“I’ve avoided software because it all feels clinical and cold. This actually feels like it understands holistic work.”',
                  name: '– Acupuncturist, Brighton',
                },
              ].map((testimonial) => (
                <div
                  key={testimonial.quote}
                  className="rounded-2xl border border-white/10 bg-slate-900/50 p-6 shadow-lg shadow-purple-500/10 backdrop-blur"
                >
                  <p className="text-sm text-slate-200">{testimonial.quote}</p>
                  <p className="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">
                    {testimonial.name}
                  </p>
                </div>
              ))}
            </div>
            <p className="text-xs text-slate-400">20+ UK practitioners have already registered interest.</p>
          </section>

          <section id="evidence" className="space-y-12">
            <div className="max-w-xl space-y-4">
              <h2 className="text-3xl font-semibold text-white sm:text-4xl">
                We’re bringing standards to holistic care.
              </h2>
            </div>
            <div className="grid gap-10 lg:grid-cols-2">
              <ul className="space-y-4 text-sm text-slate-300">
                {[
                  'Verified practitioner credentials',
                  'Outcome tracking over time',
                  'Anonymised data to support research and policy',
                  'Designed to meet UK data privacy standards',
                ].map((item) => (
                  <li key={item} className="flex items-start gap-3">
                    <span className="mt-1 inline-flex h-5 w-5 items-center justify-center rounded-full bg-purple-500/30 text-sm text-purple-100">
                      •
                    </span>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
              <div className="flex flex-col gap-4 rounded-3xl border border-white/10 bg-slate-900/60 p-6 shadow-lg shadow-indigo-500/10 backdrop-blur">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-semibold text-slate-200">Your Practice Report</p>
                  <span className="rounded-full bg-indigo-500/20 px-3 py-1 text-xs font-medium text-indigo-100">
                    Private
                  </span>
                </div>
                <div className="space-y-3 text-sm text-slate-300">
                  <div className="flex items-center justify-between rounded-xl border border-white/5 bg-slate-950/40 px-4 py-3">
                    <span>Outcomes improvement</span>
                    <span className="font-semibold text-emerald-300">72%</span>
                  </div>
                  <div className="flex items-center justify-between rounded-xl border border-white/5 bg-slate-950/40 px-4 py-3">
                    <span>Client retention (90 days)</span>
                    <span className="font-semibold text-emerald-300">81%</span>
                  </div>
                  <div className="flex items-center justify-between rounded-xl border border-white/5 bg-slate-950/40 px-4 py-3">
                    <span>Credibility score</span>
                    <span className="font-semibold text-indigo-200">86 / 100</span>
                  </div>
                </div>
                <p className="text-xs text-slate-400">You own your data. We never sell individual health records.</p>
              </div>
            </div>
          </section>

          <section
            id="waitlist"
            className="rounded-3xl border border-white/10 bg-gradient-to-br from-slate-950 via-slate-900 to-indigo-950/20 p-10 text-center shadow-[0_0_80px_-30px_rgba(99,102,241,0.6)]"
          >
            <div className="mx-auto max-w-xl space-y-6">
              <h2 className="text-3xl font-semibold text-white sm:text-4xl">Be first to get access.</h2>
              <p className="text-sm text-slate-300">
                We’re onboarding the first 100 practitioners in the UK. After that, invite-only.
              </p>
              <div className="rounded-2xl border border-white/10 bg-slate-900/60 p-6 backdrop-blur">
                <WaitlistForm variant="cta" />
              </div>
              <p className="text-sm text-slate-400">We will contact you personally before launch.</p>
            </div>
          </section>
        </main>

        <footer className="border-t border-white/5 bg-slate-950/80">
          <div className="mx-auto flex max-w-6xl flex-col justify-between gap-8 px-6 py-10 md:flex-row">
            <div className="space-y-3 text-sm text-slate-300">
              <p className="text-lg font-semibold text-white">SANA</p>
              <p>SANA Technologies Ltd · United Kingdom</p>
              <p>Evidence-based wellness infrastructure.</p>
            </div>
            <div className="space-y-2 text-sm text-slate-300">
              <a href="#" className="block transition hover:text-white">
                Privacy
              </a>
              <a href="#" className="block transition hover:text-white">
                Terms
              </a>
              <a href="mailto:founder@mysana.io" className="block transition hover:text-white">
                Contact: founder@mysana.io
              </a>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
};

export default IndexPage;
