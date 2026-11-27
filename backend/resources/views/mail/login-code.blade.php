<x-mail::message>
@if ($language === 'km')
# លេខកូដចូលរបស់អ្នក

<x-mail::panel>
<span style="font-size: 28px; font-weight: 700; letter-spacing: 6px;">{{ $code }}</span>
</x-mail::panel>

សូមបញ្ចូលលេខកូដនេះនៅក្នុងកម្មវិធី HomeCoffee។ វាប្រើបានរយៈពេល {{ $minutes }} នាទី។

ប្រសិនបើអ្នកមិនបានស្នើសុំលេខកូដនេះទេ សូមមិនអើពើនឹងអ៊ីមែលនេះ។
@else
# Your sign-in code

<x-mail::panel>
<span style="font-size: 28px; font-weight: 700; letter-spacing: 6px;">{{ $code }}</span>
</x-mail::panel>

Enter this code in the HomeCoffee app. It works for {{ $minutes }} minutes.

If you didn't ask for a code, you can ignore this email.
@endif
</x-mail::message>
