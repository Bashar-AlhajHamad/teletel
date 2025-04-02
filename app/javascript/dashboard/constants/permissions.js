export const AVAILABLE_CUSTOM_ROLE_PERMISSIONS = [
  'conversation_manage',
  'conversation_unassigned_manage',
  'conversation_participating_manage',
  'knowledge_base_manage',
  'campaign_show',
  'campaign_create',
  'campaign_update',
  'campaign_destroy',
  'reports_show',
  'reports_download',
  'contact_show',
  'contact_create',
  'contact_update',
  'contact_destroy',
  'contact_import',
  'contact_export',
  'contact_merge',
  'contact_block',
];

export const ROLES = ['agent', 'administrator'];

export const CONVERSATION_PERMISSIONS = [
  'conversation_manage',
  'conversation_unassigned_manage',
  'conversation_participating_manage',
];

export const MANAGE_ALL_CONVERSATION_PERMISSIONS = 'conversation_manage';

export const CONVERSATION_UNASSIGNED_PERMISSIONS =
  'conversation_unassigned_manage';

export const CONVERSATION_PARTICIPATING_PERMISSIONS =
  'conversation_participating_manage';

export const CAMPAIGN_PERMISSIONS = [
  'campaign_show',
  'campaign_create',
  'campaign_update',
  'campaign_destroy',
];

export const CONTACT_PERMISSIONS = [
  'contact_show',
  'contact_create',
  'contact_update',
  'contact_destroy',
  'contact_import',
  'contact_export',
  'contact_merge',
  'contact_block',
];

export const REPORTS_PERMISSIONS = ['reports_show', 'reports_download'];

export const PORTAL_PERMISSIONS = 'knowledge_base_manage';

export const ASSIGNEE_TYPE_TAB_PERMISSIONS = {
  me: {
    count: 'mineCount',
    permissions: [
      ...ROLES,
      ...CONVERSATION_PERMISSIONS,
      ...CONTACT_PERMISSIONS,
      ...CAMPAIGN_PERMISSIONS,
    ],
  },
  unassigned: {
    count: 'unAssignedCount',
    permissions: [
      ...ROLES,
      MANAGE_ALL_CONVERSATION_PERMISSIONS,
      CONVERSATION_UNASSIGNED_PERMISSIONS,
    ],
  },
  all: {
    count: 'allCount',
    permissions: [
      ...ROLES,
      MANAGE_ALL_CONVERSATION_PERMISSIONS,
      CONVERSATION_PARTICIPATING_PERMISSIONS,
    ],
  },
};
