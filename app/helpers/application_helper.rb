module ApplicationHelper
  def avatar_helper(user = Current.user)
    user_avatar(user)
  end

  def user_avatar(user = Current.user, size: "w-9 h-9")
    return unless user

    if user.profile_photo.present?
      image_tag user.profile_photo,
        alt: user.name,
        class: "#{size} rounded-full object-cover border border-gray-200 shadow-sm"
    else
      content_tag :div,
        user_initials(user),
        class: "#{size} rounded-full bg-slate-800 text-white font-semibold text-xs flex items-center justify-center uppercase tracking-wide select-none shadow-sm",
        title: user.name
    end
  end

  def user_initials(user)
    return "?" if user&.name.blank?

    parts = user.name.strip.split(/\s+/)
    if parts.length >= 2
      "#{parts.first[0]}#{parts.last[0]}".upcase
    else
      user.name.strip[0..1].upcase
    end
  end
end
