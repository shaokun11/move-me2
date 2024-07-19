import {RECAPTCHA_SECRET} from "./const.js";
import { createHash } from "node:crypto"
const GOOGLE_TOKEN_SET = new Set();
export async function googleRecaptcha(token) {
    // no secret key provided, just skip and return true
    if (!RECAPTCHA_SECRET) return true;
    if (!token) return false;
    const t1 = createHash("sha256").update(token).digest("hex")
    if (GOOGLE_TOKEN_SET.has(t1)) {
        return false
    }
    GOOGLE_TOKEN_SET.add(t1);
    const keys = RECAPTCHA_SECRET.split(',');
    for (const key of keys) {
        const pass = await fetch('https://www.google.com/recaptcha/api/siteverify', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `secret=${key}&response=${token}`,
        })
            .then(response => response.json())
            .then(res => res.success)
            .catch(() => false);
        if (pass) return true;
    }
    return false
}