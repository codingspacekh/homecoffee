<?php

use Illuminate\Support\Facades\Route;

// Public pages. The app stores link to the privacy policy and the
// delete-account page, so keep these addresses as they are.
Route::view('/', 'site.home')->name('home');
Route::view('/privacy', 'site.privacy')->name('privacy');
Route::view('/delete-account', 'site.delete-account')->name('delete-account');
