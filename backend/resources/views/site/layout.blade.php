<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title }} · HomeCoffee</title>
    <meta name="description" content="{{ $description ?? 'Order ahead and skip the line.' }}">
    <link rel="stylesheet" href="{{ asset('fonts/homecoffee/fonts.css') }}">
    <style>
        :root { --bg: #fff8f5; --card: #ffffff; --text: #231a15; --muted: #5c4f47; --brand: #7b4b2a; --line: #eadfd8; }
        @media (prefers-color-scheme: dark) {
            :root { --bg: #19120e; --card: #231a15; --text: #f3e9e3; --muted: #cbbdb4; --brand: #f1b993; --line: #3a2e27; }
        }
        * { box-sizing: border-box; }
        body { margin: 0; background: var(--bg); color: var(--text); font: 17px/1.6 'Figtree', 'Noto Sans Khmer', system-ui, sans-serif; }
        main { max-width: 720px; margin: 0 auto; padding: 32px 16px 64px; }
        header { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 32px; }
        .brand { font-weight: 800; font-size: 22px; color: var(--text); text-decoration: none; }
        nav a { color: var(--muted); margin-left: 16px; font-size: 15px; }
        h1 { font-size: 34px; line-height: 1.2; margin: 0 0 8px; }
        h2 { font-size: 21px; margin: 32px 0 8px; }
        p, li { color: var(--text); }
        .muted { color: var(--muted); }
        a { color: var(--brand); }
        .card { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 20px; margin: 16px 0; }
        ul { padding-left: 22px; }
        footer { margin-top: 48px; padding-top: 16px; border-top: 1px solid var(--line); font-size: 15px; color: var(--muted); }
    </style>
</head>
<body>
<main>
    <header>
        <a class="brand" href="{{ url('/') }}">HomeCoffee</a>
        <nav><a href="{{ route('privacy') }}">Privacy</a><a href="{{ route('delete-account') }}">Delete account</a></nav>
    </header>
    {{ $slot }}
    <footer>{{ config('homecoffee.operator') }} · <a href="mailto:{{ config('homecoffee.contact_email') }}">{{ config('homecoffee.contact_email') }}</a></footer>
</main>
</body>
</html>
