module Policr
  class AfterEventCallback < Callback
    def initialize(bot)
      super(bot, "AfterEvent")
    end

    def handle(query, msg, report)
      chat_id = msg.chat.id
      from_user_id = query.from.id
      member_id, username, item, msg_id = report

      case item
      when "torture"                      # 开始验证
        if from_user_id != member_id.to_i # 无关人士
          bot.answer_callback_query(query.id, text: t("unrelated_warning"), show_alert: true)
          return
        end
        if (join_user_handler = bot.handlers[:join_user]) && join_user_handler.is_a?(JoinUserHandler)
          join_user_handler.promptly_torture(msg.chat.id, msg_id.to_i, member_id.to_i, username)
          bot.delete_message(msg.chat.id, msg.message_id)
        end
      when "unban" # 解封
        # 检测权限
        unless bot.is_admin? chat_id, from_user_id
          bot.answer_callback_query(query.id, text: t("callback.no_permission"), show_alert: true)
          return
        end
        # 初始化用户权限
        bot.restrict_chat_member(msg.chat.id, member_id.to_i, can_send_messages: true, can_send_media_messages: true, can_send_other_messages: true, can_add_web_page_previews: true)
        bot.delete_message(msg.chat.id, msg.message_id)
      when "kick" # 移除
        # 检测权限
        unless bot.is_admin? chat_id, from_user_id
          bot.answer_callback_query(query.id, text: t("callback.no_permission"), show_alert: true)
          return
        end
        bot.kick_chat_member(msg.chat.id, member_id.to_i)
        bot.delete_message(msg.chat.id, msg.message_id)
      end
    end
  end
end
