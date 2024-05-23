export async function googleRecaptcha(token) {
    // no secret key provided, just skip and return true
    if (!RECAPTCHA_SECRET) return true;
    if (!token) return false;
    const keys = RECAPTCHA_SECRET.split(',');
    const result = await Promise.all(keys.map(key => fetch('https://www.google.com/recaptcha/api/siteverify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `secret=${key}&response=${token}`,
    })
        .then(response => response.json())
        .then(res => res.success)
        .catch(() => false)));
    return result.some(r => r);
}