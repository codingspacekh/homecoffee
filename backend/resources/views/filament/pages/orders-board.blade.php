@php
    use App\Models\StoreSetting;

    $timezone = StoreSetting::current()->timezone;
    $time = fn ($moment) => $moment?->copy()->setTimezone($timezone)->format('g:i A');
    $columns = [
        'received' => ['title' => 'New', 'next' => 'Start', 'color' => 'warning', 'empty' => 'No new orders'],
        'preparing' => ['title' => 'Preparing', 'next' => 'Ready', 'color' => 'primary', 'empty' => 'Nothing being made'],
        'ready' => ['title' => 'Ready for pickup', 'next' => 'Picked up', 'color' => 'success', 'empty' => 'Nothing waiting'],
    ];
@endphp

<x-filament-panels::page>
    <style>
        .hc-board { display: grid; gap: 1rem; grid-template-columns: repeat(3, minmax(0, 1fr)); align-items: start; }
        @media (max-width: 900px) { .hc-board { grid-template-columns: minmax(0, 1fr); } }
        .hc-column { border-radius: 1rem; padding: .75rem; background: var(--gray-100); min-height: 12rem; }
        .dark .hc-column { background: color-mix(in oklab, var(--gray-800) 60%, transparent); }
        .hc-column-head { display: flex; align-items: center; justify-content: space-between; padding: .25rem .25rem .75rem; }
        .hc-column-title { font-size: 1.125rem; font-weight: 700; color: var(--gray-950); }
        .dark .hc-column-title { color: white; }
        .hc-count { min-width: 2rem; padding: .125rem .625rem; border-radius: 999px; font-weight: 700; text-align: center; }
        .hc-count-warning { background: var(--warning-100); color: var(--warning-800); }
        .hc-count-primary { background: var(--primary-100); color: var(--primary-800); }
        .hc-count-success { background: var(--success-100); color: var(--success-800); }
        .hc-cards { display: flex; flex-direction: column; gap: .75rem; }
        .hc-card { border-radius: .875rem; padding: 1rem; background: white; border: 1px solid var(--gray-200); border-left: 6px solid var(--gray-300); }
        .dark .hc-card { background: var(--gray-900); border-color: var(--gray-700); }
        .hc-card-warning { border-left-color: var(--warning-500); }
        .hc-card-primary { border-left-color: var(--primary-500); }
        .hc-card-success { border-left-color: var(--success-500); }
        .hc-card.hc-late { box-shadow: 0 0 0 2px var(--danger-500); }
        .hc-top { display: flex; flex-wrap: wrap; align-items: baseline; justify-content: space-between; column-gap: .75rem; }
        .hc-number { font-size: 1.75rem; font-weight: 800; line-height: 1.1; color: var(--gray-950); }
        .dark .hc-number { color: white; }
        .hc-when { font-size: .9375rem; font-weight: 700; color: var(--gray-700); white-space: nowrap; }
        .dark .hc-when { color: var(--gray-200); }
        .hc-late-label { color: var(--danger-600); }
        .dark .hc-late-label { color: var(--danger-400); }
        .hc-name { margin-top: .125rem; font-size: 1rem; font-weight: 600; color: var(--gray-800); }
        .dark .hc-name { color: var(--gray-100); }
        .hc-meta { font-size: .875rem; color: var(--gray-600); }
        .dark .hc-meta { color: var(--gray-300); }
        .hc-lines { margin: .75rem 0; padding: .75rem 0; border-top: 1px solid var(--gray-200); border-bottom: 1px solid var(--gray-200); display: flex; flex-direction: column; gap: .5rem; }
        .dark .hc-lines { border-color: var(--gray-700); }
        .hc-line { font-size: 1.0625rem; color: var(--gray-950); }
        .dark .hc-line { color: white; }
        .hc-qty { font-weight: 800; margin-right: .25rem; }
        .hc-choices { display: block; font-size: .9375rem; color: var(--gray-700); }
        .dark .hc-choices { color: var(--gray-300); }
        .hc-note { display: inline-block; margin-top: .25rem; padding: .125rem .5rem; border-radius: .375rem; font-size: .9375rem; font-weight: 600; background: var(--warning-100); color: var(--warning-900); }
        .hc-bottom { display: flex; align-items: center; justify-content: space-between; gap: .5rem; flex-wrap: wrap; }
        .hc-pay { font-size: .9375rem; color: var(--gray-700); }
        .dark .hc-pay { color: var(--gray-300); }
        .hc-pay strong { color: var(--gray-950); font-size: 1.0625rem; }
        .dark .hc-pay strong { color: white; }
        .hc-free { margin-left: .375rem; padding: .0625rem .5rem; border-radius: 999px; font-size: .8125rem; font-weight: 700; background: var(--success-100); color: var(--success-800); }
        .hc-actions { display: flex; align-items: center; gap: .75rem; }
        .hc-empty { padding: 2rem .5rem; text-align: center; font-size: 1rem; color: var(--gray-600); }
        .dark .hc-empty { color: var(--gray-300); }
        .hc-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; margin-bottom: .25rem; }
        .hc-hint { font-size: .9375rem; color: var(--gray-700); }
        .dark .hc-hint { color: var(--gray-300); }
    </style>

    <script>
        // Chime and keep the screen on. Browsers only allow sound after a
        // tap, so the barista turns it on once per shift.
        window.hcBoard = () => ({
            sound: localStorage.getItem('hc.board.sound') === 'on',
            audio: null,
            lock: null,
            init() {
                if (this.sound) this.keepAwake();
                document.addEventListener('visibilitychange', () => {
                    if (document.visibilityState === 'visible' && this.sound) this.keepAwake();
                });
            },
            toggleSound() {
                this.sound = !this.sound;
                localStorage.setItem('hc.board.sound', this.sound ? 'on' : 'off');
                if (this.sound) {
                    this.unlock();
                    this.chime();
                    this.keepAwake();
                } else {
                    this.lock?.release();
                    this.lock = null;
                }
            },
            unlock() {
                this.audio ??= new (window.AudioContext || window.webkitAudioContext)();
                this.audio.resume();
            },
            async keepAwake() {
                try { this.lock = await navigator.wakeLock?.request('screen'); } catch (e) {}
            },
            chime() {
                if (!this.sound) return;
                this.unlock();
                const start = this.audio.currentTime;
                [880, 1175, 1568].forEach((frequency, i) => {
                    const at = start + i * 0.16;
                    const tone = this.audio.createOscillator();
                    const volume = this.audio.createGain();
                    tone.frequency.value = frequency;
                    volume.gain.setValueAtTime(0.0001, at);
                    volume.gain.exponentialRampToValueAtTime(0.5, at + 0.02);
                    volume.gain.exponentialRampToValueAtTime(0.0001, at + 0.4);
                    tone.connect(volume).connect(this.audio.destination);
                    tone.start(at);
                    tone.stop(at + 0.45);
                });
            },
        });
    </script>

    <div
        x-data="hcBoard()"
        x-on:new-order.window="chime()"
        x-on:click="sound && unlock()"
        wire:poll.5s="refreshBoard"
    >
        <div class="hc-toolbar">
            <p class="hc-hint">New orders appear by themselves. Tap a button to move an order on.</p>
            <x-filament::button
                x-on:click.stop="toggleSound()"
                color="gray"
                icon="heroicon-o-speaker-wave"
            >
                <span x-text="sound ? 'Sound on' : 'Turn on sound'">Turn on sound</span>
            </x-filament::button>
        </div>

        <div class="hc-board">
            @foreach ($columns as $status => $column)
                @php($orders = $this->columns[$status])
                <section class="hc-column" aria-label="{{ $column['title'] }}">
                    <div class="hc-column-head">
                        <h2 class="hc-column-title">{{ $column['title'] }}</h2>
                        <span class="hc-count hc-count-{{ $column['color'] }}">{{ $orders->count() }}</span>
                    </div>
                    <div class="hc-cards">
                        @forelse ($orders as $order)
                            @php($late = $status !== 'ready' && now()->greaterThan($order->estimated_ready_at))
                            <article
                                wire:key="order-{{ $order->id }}-{{ $order->status->value }}"
                                class="hc-card hc-card-{{ $column['color'] }} {{ $late ? 'hc-late' : '' }}"
                            >
                                <div class="hc-top">
                                    <span class="hc-number">#{{ $order->number() }}</span>
                                    <span class="hc-when">
                                        @if ($status === 'ready')
                                            Ready since {{ $time($order->ready_at) }}
                                        @elseif ($order->pickup_at)
                                            <span @class(['hc-late-label' => $late])>Pickup {{ $time($order->pickup_at) }}</span>
                                        @else
                                            <span @class(['hc-late-label' => $late])>{{ $late ? 'Late, was due' : 'Due' }} {{ $time($order->estimated_ready_at) }}</span>
                                        @endif
                                    </span>
                                </div>
                                <div class="hc-name">{{ $order->customer_name }}</div>
                                <div class="hc-meta">
                                    Ordered {{ $time($order->created_at) }}@if ($order->customer_phone), {{ $order->customer_phone }}@endif
                                </div>

                                <div class="hc-lines">
                                    @foreach ($order->lines as $line)
                                        <div class="hc-line">
                                            <span class="hc-qty">{{ $line->quantity }} ×</span> {{ $line->translated('name') }}
                                            @if (filled($line->translated('choices')))
                                                <span class="hc-choices">{{ $line->translated('choices') }}</span>
                                            @endif
                                            @if (filled($line->note))
                                                <span class="hc-note">Note: {{ $line->note }}</span>
                                            @endif
                                        </div>
                                    @endforeach
                                </div>

                                <div class="hc-bottom">
                                    <span class="hc-pay">
                                        <strong>{{ \App\Domain\Money::format($order->total_cents) }}</strong> at the counter
                                        @if ($order->points_spent > 0)
                                            <span class="hc-free">Free drink</span>
                                        @endif
                                    </span>
                                    <span class="hc-actions">
                                        {{ ($this->cancelAction)(['order' => $order->id]) }}
                                        <x-filament::button
                                            wire:click="advance({{ $order->id }}, '{{ $order->status->value }}')"
                                            wire:loading.attr="disabled"
                                            wire:target="advance({{ $order->id }}, '{{ $order->status->value }}')"
                                            :color="$column['color']"
                                            size="lg"
                                        >
                                            {{ $column['next'] }}
                                        </x-filament::button>
                                    </span>
                                </div>
                            </article>
                        @empty
                            <p class="hc-empty">{{ $column['empty'] }}</p>
                        @endforelse
                    </div>
                </section>
            @endforeach
        </div>
    </div>
</x-filament-panels::page>
