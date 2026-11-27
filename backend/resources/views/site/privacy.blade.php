<x-site-layout title="Privacy policy" description="What the HomeCoffee app collects, why, and how to delete it.">
    <h1>Privacy policy</h1>
    <p class="muted">Last updated {{ \Illuminate\Support\Carbon::parse('2026-11-27')->format('j F Y') }}</p>

    <p>HomeCoffee is an app for ordering coffee ahead and picking it up at the counter, run by {{ config('homecoffee.operator') }}. This page explains what the app keeps about you and why. In short: only what it needs to take your order and count your points. No ads, no tracking, and nothing is sold.</p>

    <h2>What we keep</h2>
    <ul>
        <li><strong>Your email address</strong>, to send you a sign-in code. There are no passwords.</li>
        <li><strong>Your name and phone number</strong>, if you give them at checkout, so the barista can call your order and reach you about it.</li>
        <li><strong>Your orders</strong>: what you ordered, the total, the pickup time, and any note you wrote.</li>
        <li><strong>Your points</strong>: points earned and spent, including points a barista adds when you pay at the counter, and the 8-digit member code on your Rewards tab.</li>
        <li><strong>Your favourites and your language</strong>, so the app opens the way you left it.</li>
        <li><strong>Server logs</strong> with your network address, to stop abuse such as someone guessing sign-in codes. They are deleted after 14 days.</li>
    </ul>
    <p>The app keeps your cart and settings on your phone. It has no analytics or advertising code, and it doesn't use your location, contacts, camera or photos.</p>

    <h2>Who else handles it</h2>
    <ul>
        <li>The server that runs the app, in a data centre in Singapore.</li>
        <li>An email service that delivers your sign-in codes.</li>
        <li>A cloud storage service that keeps encrypted nightly backups.</li>
    </ul>
    <p>They handle your data only to provide those services. Shop staff see your name, phone, orders and points in the shop's admin panel.</p>

    <h2>How long we keep it</h2>
    <p>Your account stays until you delete it. When you do, your account, email, points, favourites and sign-in are deleted at once. Your past orders stay in the shop's sales records, but without your name or phone number. Backups are deleted after 4 months, so deleted data leaves the backups within 4 months too.</p>

    <h2>Your choices</h2>
    <ul>
        <li>Change your name, phone and language in the app under <strong>Account</strong>.</li>
        <li>Delete your account in the app under <strong>Account &gt; Forget my data</strong>, or see <a href="{{ route('delete-account') }}">how to delete your account</a>.</li>
        <li>Ask what we keep about you, or ask us to correct it, by emailing <a href="mailto:{{ config('homecoffee.contact_email') }}">{{ config('homecoffee.contact_email') }}</a>.</li>
    </ul>

    <h2>Children</h2>
    <p>HomeCoffee isn't meant for children under 13, and we don't knowingly keep their data.</p>

    <h2>Changes</h2>
    <p>If this policy changes, the new version will be on this page with a new date.</p>
</x-site-layout>
