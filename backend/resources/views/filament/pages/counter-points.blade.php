@php
    use App\Domain\Loyalty;
    use App\Models\StoreSetting;

    $timezone = StoreSetting::current()->timezone;
    $customer = $this->customer;
    $preview = $this->previewPoints();
@endphp

<x-filament-panels::page>
    <style>
        .hc-counter { display: grid; gap: 1rem; grid-template-columns: minmax(0, 3fr) minmax(0, 2fr); align-items: start; }
        @media (max-width: 900px) { .hc-counter { grid-template-columns: minmax(0, 1fr); } }
        .hc-panel { border-radius: 1rem; padding: 1.25rem; background: white; border: 1px solid var(--gray-200); }
        .dark .hc-panel { background: var(--gray-900); border-color: var(--gray-700); }
        .hc-label { display: block; font-size: .9375rem; font-weight: 600; margin-bottom: .5rem; color: var(--gray-950); }
        .dark .hc-label { color: white; }
        .hc-row { display: flex; gap: .5rem; flex-wrap: wrap; align-items: center; }
        .hc-input { flex: 1 1 14rem; min-width: 0; font-size: 1.25rem; padding: .75rem 1rem; border-radius: .75rem; border: 1px solid var(--gray-300); background: white; color: var(--gray-950); }
        .dark .hc-input { background: var(--gray-950); border-color: var(--gray-700); color: white; }
        .hc-input:focus { outline: 2px solid var(--primary-500); outline-offset: 1px; }
        .hc-error { margin-top: .5rem; color: var(--danger-600); font-size: .9375rem; }
        .dark .hc-error { color: var(--danger-400); }
        .hc-hint { margin-top: .5rem; color: var(--gray-600); font-size: .9375rem; }
        .dark .hc-hint { color: var(--gray-400); }
        .hc-video { margin-top: 1rem; width: 100%; max-height: 22rem; border-radius: .75rem; background: black; object-fit: cover; }
        .hc-member { display: flex; justify-content: space-between; gap: 1rem; align-items: start; flex-wrap: wrap; }
        .hc-name { font-size: 1.5rem; font-weight: 800; color: var(--gray-950); }
        .dark .hc-name { color: white; }
        .hc-meta { color: var(--gray-600); margin-top: .25rem; }
        .dark .hc-meta { color: var(--gray-400); }
        .hc-points { text-align: right; }
        .hc-points strong { display: block; font-size: 2.25rem; line-height: 1; font-weight: 800; color: var(--primary-600); }
        .dark .hc-points strong { color: var(--primary-400); }
        .hc-bar { margin: 1rem 0 1.25rem; height: .5rem; border-radius: 999px; background: var(--gray-200); overflow: hidden; }
        .dark .hc-bar { background: var(--gray-700); }
        .hc-bar span { display: block; height: 100%; background: var(--primary-500); }
        .hc-choices { display: flex; flex-direction: column; gap: .5rem; margin-top: 1rem; }
        .hc-choice { text-align: left; padding: .75rem 1rem; border-radius: .75rem; border: 1px solid var(--gray-200); background: var(--gray-50); }
        .dark .hc-choice { border-color: var(--gray-700); background: var(--gray-800); }
        .hc-list { display: flex; flex-direction: column; }
        .hc-entry { display: flex; justify-content: space-between; gap: .75rem; padding: .625rem 0; border-top: 1px solid var(--gray-200); }
        .dark .hc-entry { border-color: var(--gray-700); }
        .hc-entry:first-child { border-top: 0; }
        .hc-plus { font-weight: 700; color: var(--success-600); white-space: nowrap; }
        .hc-minus { font-weight: 700; color: var(--danger-600); white-space: nowrap; }
        .hc-heading { font-size: 1.0625rem; font-weight: 700; margin-bottom: .5rem; color: var(--gray-950); }
        .dark .hc-heading { color: white; }
    </style>

    <script>
        // Reads the member QR with the tablet camera: the browser's own
        // barcode reader where there is one, otherwise jsQR (iPad Safari).
        window.hcScanner = () => ({
            scanning: false,
            problem: '',
            stream: null,
            detector: null,
            canvas: null,
            async start() {
                this.problem = '';
                try {
                    this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
                } catch (e) {
                    this.problem = 'The camera is not available. Type the member code instead.';
                    return;
                }
                this.scanning = true;
                await this.$nextTick();
                this.$refs.video.srcObject = this.stream;
                await this.$refs.video.play();
                if ('BarcodeDetector' in window) {
                    this.detector = new BarcodeDetector({ formats: ['qr_code'] });
                } else if (!window.jsQR) {
                    await new Promise((resolve, reject) => {
                        const script = document.createElement('script');
                        script.src = @js(asset('vendor/jsqr/jsQR.js'));
                        script.onload = resolve;
                        script.onerror = reject;
                        document.head.appendChild(script);
                    });
                }
                this.look();
            },
            async look() {
                if (!this.scanning) return;
                const video = this.$refs.video;
                let text = null;
                if (video.readyState >= 2) {
                    if (this.detector) {
                        const codes = await this.detector.detect(video).catch(() => []);
                        text = codes[0]?.rawValue ?? null;
                    } else if (window.jsQR) {
                        this.canvas ??= document.createElement('canvas');
                        this.canvas.width = video.videoWidth;
                        this.canvas.height = video.videoHeight;
                        const context = this.canvas.getContext('2d', { willReadFrequently: true });
                        context.drawImage(video, 0, 0);
                        const image = context.getImageData(0, 0, this.canvas.width, this.canvas.height);
                        text = window.jsQR(image.data, image.width, image.height)?.data ?? null;
                    }
                }
                if (text) {
                    this.stop();
                    this.$wire.scanned(text);
                } else {
                    setTimeout(() => this.look(), 200);
                }
            },
            stop() {
                this.scanning = false;
                this.stream?.getTracks().forEach((track) => track.stop());
                this.stream = null;
            },
        });
    </script>

    <div class="hc-counter">
        <div class="hc-panel" x-data="hcScanner()" x-on:livewire:navigating.window="stop()">
            @if ($customer === null)
                <label class="hc-label" for="hc-lookup">Member code, phone or email</label>
                <form class="hc-row" wire:submit="find">
                    <input
                        id="hc-lookup"
                        class="hc-input"
                        type="text"
                        autocomplete="off"
                        autofocus
                        placeholder="1234 5678"
                        wire:model="lookup"
                    >
                    <x-filament::button type="submit" size="xl">Find</x-filament::button>
                    <x-filament::button type="button" size="xl" color="gray" icon="heroicon-o-qr-code" x-show="!scanning" x-on:click="start()">
                        Scan QR
                    </x-filament::button>
                    <x-filament::button type="button" size="xl" color="gray" x-show="scanning" x-cloak x-on:click="stop()">
                        Stop camera
                    </x-filament::button>
                </form>
                @error('lookup') <p class="hc-error">{{ $message }}</p> @enderror
                <p class="hc-error" x-show="problem" x-text="problem" x-cloak></p>
                <p class="hc-hint">The customer opens the Rewards tab in the app to show their member QR.</p>
                <video class="hc-video" x-ref="video" x-show="scanning" x-cloak playsinline muted></video>

                @if ($this->choices->isNotEmpty())
                    <div class="hc-choices">
                        <p class="hc-label">More than one member has this phone. Which one?</p>
                        @foreach ($this->choices as $choice)
                            <button type="button" class="hc-choice" wire:click="pick({{ $choice->id }})">
                                <strong>{{ $this->displayName($choice) }}</strong>, {{ $choice->email }}, {{ $choice->points }} points
                            </button>
                        @endforeach
                    </div>
                @endif
            @else
                <div class="hc-member">
                    <div>
                        <div class="hc-name">{{ $this->displayName($customer) }}</div>
                        <div class="hc-meta">Member {{ $customer->memberCodeLabel() }}@if ($customer->phone), {{ $customer->phone }}@endif</div>
                    </div>
                    <div class="hc-points">
                        <strong>{{ $customer->points }}</strong>
                        points
                    </div>
                </div>
                <div class="hc-bar" title="{{ min($customer->points, Loyalty::REWARD_POINTS) }} of {{ Loyalty::REWARD_POINTS }}">
                    <span style="width: {{ min(100, intdiv($customer->points * 100, Loyalty::REWARD_POINTS)) }}%"></span>
                </div>

                <label class="hc-label" for="hc-amount">Amount paid</label>
                <form class="hc-row" wire:submit="addPoints">
                    <input
                        id="hc-amount"
                        class="hc-input"
                        type="text"
                        inputmode="decimal"
                        autocomplete="off"
                        autofocus
                        placeholder="$0.00"
                        wire:model.live.debounce.300ms="amount"
                    >
                    <x-filament::button type="submit" size="xl" wire:loading.attr="disabled" wire:target="addPoints">
                        Add points
                    </x-filament::button>
                </form>
                @error('amount')
                    <p class="hc-error">{{ $message }}</p>
                @else
                    <p class="hc-hint">
                        @if ($preview !== null)
                            Earns {{ $preview }} {{ $preview === 1 ? 'point' : 'points' }}.
                        @else
                            One point for each whole dollar.
                        @endif
                    </p>
                @enderror

                <div class="hc-row" style="margin-top: 1.5rem; justify-content: space-between;">
                    @if (Loyalty::hasReward($customer->points))
                        <x-filament::button
                            color="success"
                            icon="heroicon-o-gift"
                            wire:click="giveFreeDrink"
                            wire:confirm="Give {{ $this->displayName($customer) }} a free drink for {{ Loyalty::REWARD_POINTS }} points?"
                            wire:loading.attr="disabled"
                        >
                            Give free drink ({{ Loyalty::REWARD_POINTS }} points)
                        </x-filament::button>
                    @else
                        <span class="hc-hint" style="margin: 0">{{ Loyalty::REWARD_POINTS - $customer->points }} more points for a free drink</span>
                    @endif
                    <x-filament::link tag="button" wire:click="clear" color="gray">Next customer</x-filament::link>
                </div>
            @endif
        </div>

        <div class="hc-panel">
            <p class="hc-heading">Today at the counter</p>
            @forelse ($this->today as $entry)
                <div class="hc-entry">
                    <span>
                        <strong>{{ $entry->user ? $this->displayName($entry->user) : 'Removed account' }}</strong>
                        <span class="hc-meta" style="display: block">
                            {{ $entry->created_at->setTimezone($timezone)->format('g:i A') }}, {{ $entry->note }}@if ($entry->staff), by {{ $entry->staff->name }}@endif
                        </span>
                    </span>
                    <span class="{{ $entry->change > 0 ? 'hc-plus' : 'hc-minus' }}">{{ $entry->change > 0 ? '+' : '' }}{{ $entry->change }}</span>
                </div>
            @empty
                <p class="hc-hint" style="margin: 0">Nothing yet today.</p>
            @endforelse
            <p class="hc-hint">A mistake? A manager can fix points on the customer's page.</p>
        </div>
    </div>
</x-filament-panels::page>
