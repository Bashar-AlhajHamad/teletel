<script setup>
defineProps({
  roles: {
    type: Array,
    required: true,
  },
  loading: {
    type: Object,
    default: () => ({}),
  },
});

const emit = defineEmits(['edit', 'delete']);

const getFormattedPermissions = role => {
  // Ensure role.permissions is a valid array
  if (
    !role.permissions ||
    !Array.isArray(role.permissions) ||
    role.permissions.length === 0
  ) {
    return 'No permissions assigned';
  }

  return role.permissions
    .map(event => {
      if (!event || typeof event !== 'object') {
        return 'Invalid permission';
      }

      // Ensure event.action exists
      return event.action ? event.action : 'Unknown action';
    })
    .join(', ');
};
</script>

<template>
  <tbody class="divide-y divide-n-weak text-n-slate-11">
    <tr v-for="(customRole, index) in roles" :key="index">
      <td
        class="max-w-xs py-4 pr-4 font-medium truncate align-baseline"
        :title="customRole.name"
      >
        {{ customRole.name }}
      </td>
      <td class="py-4 pr-4 whitespace-normal align-baseline md:break-words">
        {{ customRole.description }}
      </td>
      <td class="py-4 pr-4 whitespace-normal align-baseline md:break-words">
        {{ getFormattedPermissions(customRole) }}
      </td>
      <td class="flex justify-end gap-1 py-4">
        <woot-button
          v-tooltip.top="$t('CUSTOM_ROLE.EDIT.BUTTON_TEXT')"
          variant="smooth"
          size="tiny"
          color-scheme="secondary"
          class-names="grey-btn"
          icon="edit"
          @click="emit('edit', customRole)"
        />
        <woot-button
          v-tooltip.top="$t('CUSTOM_ROLE.DELETE.BUTTON_TEXT')"
          variant="smooth"
          color-scheme="alert"
          size="tiny"
          icon="dismiss-circle"
          class-names="grey-btn"
          :is-loading="loading[customRole.id]"
          @click="emit('delete', customRole)"
        />
      </td>
    </tr>
  </tbody>
</template>
