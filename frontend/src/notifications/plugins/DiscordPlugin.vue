<template>
  <notification-channel-template
    :error-messages="errorMessages"
    :saving="saving"
    :notification-channel="notificationChannel"
    :config-variable-title="$t('Webhook URL')"
    :config-variable-placeholder="$t('Discord Webhook')"
    config-variable-name="webhook_url"
    @createNotificationChannel="onCreateChannel"
    @updateNotificationChannel="$emit('updateNotificationChannel', $event)"
    @deleteNotificationChannel="(channel) => $emit('deleteNotificationChannel', channel)"
    @clearErrorMessages="(settingKey) => $emit('clearErrorMessages', settingKey)"
  >
    <template #configuration>
      <div class="form-group">
        <label for="discord_username">{{ $t('Discord Username') }}</label>
        <input
          id="discord_username"
          v-model="discordUsername"
          type="text"
          class="form-control"
          :placeholder="$t('Your Discord username (optional)')"
        />
        <small class="form-text text-muted">
          {{ $t('Enter your Discord username to be mentioned (@) in notifications') }}
        </small>
      </div>
    </template>
    <template #header>
      <small class="form-text text-muted">
        <i18next :translation="$t('If you have a Discord channel you wish to receive notifications on, you can {localizedDom} and enter it here.')">
          <template #localizedDom>
            <a href="https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks"> {{$t("generate webhook url")}}</a>
          </template>
        </i18next>
      </small>
    </template>
  </notification-channel-template>
</template>

<script>
import NotificationChannelTemplate from '@src/components/user-preferences/notifications/NotificationChannelTemplate.vue'

export default {
  name: 'DiscordPlugin',

  components: {
    NotificationChannelTemplate,
  },

  props: {
    errorMessages: {
      type: Object,
      required: true,
    },
    saving: {
      type: Object,
      required: true,
    },
    notificationChannel: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      discordUsername: ''
    }
  },

  created() {
    if (this.notificationChannel.channelInfo?.config) {
      this.discordUsername = this.notificationChannel.channelInfo.config.discord_username || ''
    }
  },

  methods: {
    onCreateChannel(event) {
      const config = {
        ...event.config,
        discord_username: this.discordUsername
      }
      this.$emit('createNotificationChannel', {...event, config})
    }
  }
}
</script>
