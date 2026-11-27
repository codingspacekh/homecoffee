<x-site-layout title="Delete your account" description="How to delete your HomeCoffee account and what is deleted.">
    <h1>Delete your HomeCoffee account</h1>

    <div class="card">
        <h2 style="margin-top:0">In the app</h2>
        <ol>
            <li>Open HomeCoffee and go to the <strong>Account</strong> tab.</li>
            <li>Tap <strong>Forget my data</strong>, then confirm.</li>
        </ol>
        <p class="muted">It happens straight away, and you're signed out.</p>
    </div>

    <div class="card">
        <h2 style="margin-top:0">By email</h2>
        <p>If you no longer have the app, email <a href="mailto:{{ config('homecoffee.contact_email') }}?subject=Delete%20my%20HomeCoffee%20account">{{ config('homecoffee.contact_email') }}</a> from the address you sign in with, and ask us to delete your account. We'll do it within 30 days and reply when it's done.</p>
    </div>

    <h2>What is deleted</h2>
    <ul>
        <li>Your account and email address</li>
        <li>Your points, points history and member code</li>
        <li>Your favourites, language and sign-in on every phone</li>
    </ul>

    <h2>What is kept</h2>
    <p>Your past orders stay in the shop's sales records with the name changed to "Removed" and the phone number cleared, so the shop's totals still add up. Nightly backups are deleted after 4 months. See the <a href="{{ route('privacy') }}">privacy policy</a> for more.</p>
</x-site-layout>
