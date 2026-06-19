<label for="mood">Mood</label>
<input type="text" id="mood" name="mood" value="{{ old('mood', $moodFood->mood ?? '') }}" placeholder="Contoh: Bahagia, Sedih, Capek" required>
@error('mood') <small class="error">{{ $message }}</small> @enderror

<label for="food_name">Nama Makanan</label>
<input type="text" id="food_name" name="food_name" value="{{ old('food_name', $moodFood->food_name ?? '') }}" placeholder="Contoh: Bakso hangat" required>
@error('food_name') <small class="error">{{ $message }}</small> @enderror

<label for="category">Kategori</label>
<input type="text" id="category" name="category" value="{{ old('category', $moodFood->category ?? '') }}" placeholder="Contoh: Comfort Food" required>
@error('category') <small class="error">{{ $message }}</small> @enderror

<label for="taste">Rasa / Sensasi</label>
<input type="text" id="taste" name="taste" value="{{ old('taste', $moodFood->taste ?? '') }}" placeholder="Contoh: Gurih, pedas, hangat">
@error('taste') <small class="error">{{ $message }}</small> @enderror

<label for="reason">Alasan Rekomendasi</label>
<textarea id="reason" name="reason" rows="5" placeholder="Jelaskan kenapa makanan ini cocok untuk mood tersebut" required>{{ old('reason', $moodFood->reason ?? '') }}</textarea>
@error('reason') <small class="error">{{ $message }}</small> @enderror

<label class="checkbox">
    <input type="checkbox" name="is_favorite" value="1" @checked(old('is_favorite', $moodFood->is_favorite ?? false))>
    Tandai sebagai favorit
</label>