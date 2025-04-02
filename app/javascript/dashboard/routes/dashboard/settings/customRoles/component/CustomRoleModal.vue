<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import {
  AVAILABLE_CUSTOM_ROLE_PERMISSIONS,
  CAMPAIGN_PERMISSIONS,
  REPORTS_PERMISSIONS,
  CONTACT_PERMISSIONS,
} from 'dashboard/constants/permissions.js';

import WootSubmitButton from 'dashboard/components/buttons/FormSubmitButton.vue';

const props = defineProps({
  mode: {
    type: String,
    default: 'add',
    validator: value => ['add', 'edit'].includes(value),
  },
  selectedRole: {
    type: Object,
    default: () => ({}),
  },
});

const emit = defineEmits(['close']);

const store = useStore();
const { t } = useI18n();

const name = ref('');
const description = ref('');
const selectedPermissions = ref([]);

const nameInput = ref(null);

const addCustomRole = reactive({
  showLoading: false,
  message: '',
});

const rules = computed(() => ({
  name: { required, minLength: minLength(2) },
  description: { required },
  selectedPermissions: { required, minLength: minLength(1) },
}));

const v$ = useVuelidate(rules, { name, description, selectedPermissions });

const resetForm = () => {
  name.value = '';
  description.value = '';
  selectedPermissions.value = [];
  v$.value.$reset();
};

const populateEditForm = () => {
  if (!props.selectedRole) return; // ✅ Prevents errors if selectedRole is undefined

  name.value = props.selectedRole.name || '';
  description.value = props.selectedRole.description || '';

  // Ensure permissions are mapped to an array of action names
  selectedPermissions.value = props.selectedRole.permissions
    ? props.selectedRole.permissions.map(p => p.action)
    : [];
};

const allPermissions = computed(() => [
  ...AVAILABLE_CUSTOM_ROLE_PERMISSIONS,
  ...CAMPAIGN_PERMISSIONS,
  ...REPORTS_PERMISSIONS,
  ...CONTACT_PERMISSIONS,
]);

// Check if ALL permissions are selected
const isAllSelected = computed(() =>
  allPermissions.value.every(permission =>
    selectedPermissions.value.includes(permission)
  )
);

// Toggle ALL permissions
const toggleSelectAll = event => {
  selectedPermissions.value = event.target.checked
    ? [...allPermissions.value]
    : [];
};

// Campaign Permissions
const isCampaignsAllSelected = computed(() =>
  CAMPAIGN_PERMISSIONS.every(permission =>
    selectedPermissions.value.includes(permission)
  )
);

const toggleCampaignsSelectAll = event => {
  selectedPermissions.value = event.target.checked
    ? [...new Set([...selectedPermissions.value, ...CAMPAIGN_PERMISSIONS])]
    : selectedPermissions.value.filter(p => !CAMPAIGN_PERMISSIONS.includes(p));
};

// Report Permissions
const isReportsAllSelected = computed(() =>
  REPORTS_PERMISSIONS.every(permission =>
    selectedPermissions.value.includes(permission)
  )
);

const toggleReportsSelectAll = event => {
  selectedPermissions.value = event.target.checked
    ? [...new Set([...selectedPermissions.value, ...REPORTS_PERMISSIONS])]
    : selectedPermissions.value.filter(p => !REPORTS_PERMISSIONS.includes(p));
};

// Contact Permissions
const isContactsAllSelected = computed(() =>
  CONTACT_PERMISSIONS.every(permission =>
    selectedPermissions.value.includes(permission)
  )
);

const toggleContactsSelectAll = event => {
  selectedPermissions.value = event.target.checked
    ? [...new Set([...selectedPermissions.value, ...CONTACT_PERMISSIONS])]
    : selectedPermissions.value.filter(p => !CONTACT_PERMISSIONS.includes(p));
};

// Labels for permissions in the form
const permissionLabels = {
  campaign_show: 'Show',
  campaign_create: 'Create',
  campaign_update: 'Update',
  campaign_destroy: 'Destroy',
  reports_show: 'Show',
  reports_download: 'Download',
  contact_show: 'Show',
  contact_create: 'Create',
  contact_update: 'Update',
  contact_destroy: 'Destroy',
  contact_import: 'Import',
  contact_export: 'Export',
  contact_merge: 'Merge',
  contact_block: 'Block',
};

// Simplify permission translation logic
const getPermissionLabel = permission => {
  if (permissionLabels[permission]) {
    return permissionLabels[permission];
  }
  return permission; // Fallback in case the label is missing
};

const getTranslationKey = base => {
  return props.mode === 'edit'
    ? `CUSTOM_ROLE.EDIT.${base}`
    : `CUSTOM_ROLE.ADD.${base}`;
};

onMounted(() => {
  if (props.mode === 'edit') {
    populateEditForm();
  }
  // Focus the name input when mounted
  nameInput.value?.focus();
});

const modalTitle = computed(() => t(getTranslationKey('TITLE')));
const modalDescription = computed(() => t(getTranslationKey('DESC')));
const submitButtonText = computed(() => t(getTranslationKey('SUBMIT')));

const handleCustomRole = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;

  addCustomRole.showLoading = true;
  try {
    const roleData = {
      name: name.value,
      description: description.value,
      permissions: selectedPermissions.value,
    };

    if (props.mode === 'edit') {
      await store.dispatch('customRole/updateCustomRole', {
        id: props.selectedRole.id,
        ...roleData,
      });
      useAlert(t('CUSTOM_ROLE.EDIT.API.SUCCESS_MESSAGE'));
    } else {
      await store.dispatch('customRole/createCustomRole', roleData);
      useAlert(t('CUSTOM_ROLE.ADD.API.SUCCESS_MESSAGE'));
    }

    resetForm();
    emit('close');
  } catch (error) {
    const errorMessage =
      error?.message || t(`CUSTOM_ROLE.FORM.API.ERROR_MESSAGE`);
    useAlert(errorMessage);
  } finally {
    addCustomRole.showLoading = false;
  }
};

const isSubmitDisabled = computed(
  () => v$.value.$invalid || addCustomRole.showLoading
);
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto w-full mt-2 p-2">
    <woot-modal-header
      :header-title="modalTitle"
      :header-content="modalDescription"
    />
    <form class="flex flex-col w-full" @submit.prevent="handleCustomRole">
      <!-- Name Input -->
      <div class="w-full mb-6">
        <label :class="{ 'text-red-500': v$.name.$error }">
          {{ $t('CUSTOM_ROLE.FORM.NAME.LABEL') }}
          <input
            ref="nameInput"
            v-model.trim="name"
            type="text"
            class="w-full mt-1 px-3 py-2 border rounded-lg focus:ring-1 focus:ring-woot"
            :class="{ '!border-red-500': v$.name.$error }"
            :placeholder="$t('CUSTOM_ROLE.FORM.NAME.PLACEHOLDER')"
            @blur="v$.name.$touch"
          />
        </label>
      </div>

      <!-- Description Input -->
      <div class="w-full mb-6">
        <label :class="{ 'text-red-500': v$.description.$error }">
          {{ $t('CUSTOM_ROLE.FORM.DESCRIPTION.LABEL') }}
          <textarea
            v-model="description"
            rows="6"
            class="w-full mt-1 px-3 py-2 border rounded-lg focus:ring-1 focus:ring-woot"
            :class="{ error: v$.description.$error }"
            :placeholder="$t('CUSTOM_ROLE.FORM.DESCRIPTION.PLACEHOLDER')"
            required
            @blur="v$.description.$touch"
          />
        </label>
      </div>

      <!-- Permissions Section -->
      <div class="mb-6">
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-semibold mb-4">
            {{ $t('CUSTOM_ROLE.FORM.CUSTOMIZE_RESPONSIBILITIES') }}
          </h3>
          <!-- Global Select All -->
          <label class="flex items-center text-base font-medium">
            <input
              type="checkbox"
              class="form-checkbox h-5 w-5 text-woot-500"
              :checked="isAllSelected"
              @change="toggleSelectAll"
            />
            <span class="ml-2">{{
              $t('CUSTOM_ROLE.FORM.SELECT_ALL_PERMISSIONS')
            }}</span>
          </label>
        </div>

        <!-- Permission Groups -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <!-- Campaigns -->
          <div
            class="p-4 rounded-lg border border-slate-200 h-[300px] flex flex-col"
          >
            <div class="mb-3 font-medium text-slate-700">
              {{ $t('CUSTOM_ROLE.FORM.CAMPAIGNS.LABEL') }}
            </div>
            <div class="flex flex-col flex-grow justify-between gap-4">
              <div class="flex flex-wrap gap-2">
                <label
                  v-for="permission in CAMPAIGN_PERMISSIONS"
                  :key="permission"
                  class="flex items-center"
                >
                  <input
                    v-model="selectedPermissions"
                    type="checkbox"
                    :value="permission"
                    class="form-checkbox h-4 w-4 text-woot-500"
                  />
                  <span class="ml-2 text-sm">
                    {{ getPermissionLabel(permission) }}
                  </span>
                </label>
              </div>
              <!-- Keeps this section at the bottom -->
              <div class="border-t border-slate-200 pt-2 mt-auto">
                <label class="flex items-center text-sm text-slate-600">
                  <input
                    type="checkbox"
                    class="form-checkbox h-4 w-4 text-woot-500"
                    :checked="isCampaignsAllSelected"
                    @change="toggleCampaignsSelectAll"
                  />
                  <span class="ml-2">{{
                    $t('CUSTOM_ROLE.FORM.SELECT_ALL')
                  }}</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Reports -->
          <div
            class="p-4 rounded-lg border border-slate-200 h-[300px] flex flex-col"
          >
            <div class="mb-3 font-medium text-slate-700">
              {{ $t('CUSTOM_ROLE.FORM.REPORTS.LABEL') }}
            </div>
            <div class="flex flex-col flex-grow justify-between gap-4">
              <div class="flex flex-wrap gap-2">
                <label
                  v-for="permission in REPORTS_PERMISSIONS"
                  :key="permission"
                  class="flex items-center"
                >
                  <input
                    v-model="selectedPermissions"
                    type="checkbox"
                    :value="permission"
                    class="form-checkbox h-4 w-4 text-woot-500"
                  />
                  <span class="ml-2 text-sm">{{
                    getPermissionLabel(permission)
                  }}</span>
                </label>
              </div>
              <div class="border-t border-slate-200 pt-2 mt-auto">
                <label class="flex items-center text-sm text-slate-600">
                  <input
                    type="checkbox"
                    class="form-checkbox h-4 w-4 text-woot-500"
                    :checked="isReportsAllSelected"
                    @change="toggleReportsSelectAll"
                  />
                  <span class="ml-2">{{
                    $t('CUSTOM_ROLE.FORM.SELECT_ALL')
                  }}</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Contacts -->
          <div
            class="p-4 rounded-lg border border-slate-200 h-[300px] flex flex-col"
          >
            <div class="mb-3 font-medium text-slate-700">
              {{ $t('CUSTOM_ROLE.FORM.CONTACTS.LABEL') }}
            </div>
            <div class="flex flex-col flex-grow justify-between gap-4">
              <div class="flex flex-wrap gap-2">
                <label
                  v-for="permission in CONTACT_PERMISSIONS"
                  :key="permission"
                  class="flex items-center"
                >
                  <input
                    v-model="selectedPermissions"
                    type="checkbox"
                    :value="permission"
                    class="form-checkbox h-4 w-4 text-woot-500"
                  />
                  <span class="ml-2 text-sm">{{
                    getPermissionLabel(permission)
                  }}</span>
                </label>
              </div>
              <div class="border-t border-slate-200 pt-2 mt-auto">
                <label class="flex items-center text-sm text-slate-600">
                  <input
                    type="checkbox"
                    class="form-checkbox h-4 w-4 text-woot-500"
                    :checked="isContactsAllSelected"
                    @change="toggleContactsSelectAll"
                  />
                  <span class="ml-2">{{
                    $t('CUSTOM_ROLE.FORM.SELECT_ALL')
                  }}</span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="flex flex-row justify-end w-full gap-2 px-0 py-2">
        <WootSubmitButton
          :disabled="isSubmitDisabled"
          :button-text="submitButtonText"
          :loading="addCustomRole.showLoading"
        />
        <button class="button clear" @click.prevent="emit('close')">
          {{ $t('CUSTOM_ROLE.FORM.CANCEL_BUTTON_TEXT') }}
        </button>
      </div>
    </form>
  </div>
</template>
