import type { NextApiRequest, NextApiResponse } from 'next';

type WaitlistResponse =
  | { success: true }
  | { success: false; error: string };

const respondWithHtml = (res: NextApiResponse, message: string) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send(`<!DOCTYPE html><html lang="en"><head><title>SANA Waitlist</title><meta charset="utf-8" />
  <style>body{font-family:system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#020617;color:#e2e8f0;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;}div{max-width:420px;padding:2rem;border-radius:1rem;background:rgba(15,23,42,0.85);border:1px solid rgba(148,163,184,0.2);text-align:center;line-height:1.6;}a{color:#a855f7;text-decoration:none;font-weight:600;}</style></head><body><div><h1>SANA Waitlist</h1><p>${message}</p><p><a href="/">Return to the site</a></p></div></body></html>`);
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<WaitlistResponse>
) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ success: false, error: 'Method Not Allowed' });
  }

  const email = (req.body?.email || '').toString().trim();
  const role = (req.body?.role || '').toString().trim();

  if (!email || !role) {
    if (req.headers.accept?.includes('application/json')) {
      return res
        .status(400)
        .json({ success: false, error: 'Missing required fields' });
    }

    return respondWithHtml(res, 'Please provide both your email and role.');
  }

  console.log('Waitlist submission:', { email, role });

  if (req.headers.accept?.includes('application/json')) {
    return res.status(200).json({ success: true });
  }

  return respondWithHtml(res, "Thank you. You're on the list.");
}
