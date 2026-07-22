<template>
  <div class="form-group">
    <label v-if="label" class="form-label">{{ label }}</label>
    <textarea
      :value="modelValue"
      :placeholder="placeholder"
      :rows="rows"
      :class="['form-input', { 'form-input--error': error }]"
      @input="$emit('update:modelValue', $event.target.value)"
    ></textarea>
    <span v-if="error" class="form-error">{{ error }}</span>
  </div>
</template>

<script setup>
defineProps({
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  rows: { type: Number, default: 4 },
  error: { type: String, default: '' }
})

defineEmits(['update:modelValue'])
</script>

<style scoped>
.form-group { margin-bottom: 16px; }
.form-label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  margin-bottom: 4px;
}
.form-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  transition: border-color 150ms;
  box-sizing: border-box;
}
.form-input:focus {
  outline: none;
  border-color: #2563EB;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}
.form-input--error { border-color: #EF4444; }
.form-error {
  font-size: 12px;
  color: #EF4444;
  margin-top: 4px;
  display: block;
}
</style>
